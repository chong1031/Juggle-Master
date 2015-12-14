//
//  GameBoard.m
//  game
//
//  Created by Marius Rott on 26/03/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import "GameBoard.h"
#import "Ball.h"

#import "configuration.h"
#import "gameConfiguration.h"

#import "BallsUtils.h"
#import "LayoutUtils.h"
#import "SoundUtils.h"
#import "UserModel.h"

#import <Colours/Colours.h>

#define ACTION_KEY_MOVE_WALL        @"ACTION_KEY_MOVE_WALL"
#define ACTION_KEY_START_MOVE       @"ACTION_KEY_START_MOVE"

#define KEY_POSITION_COLOR          @"KEY_POSITION_COLOR"
#define KEY_POSITION_Y              @"KEY_POSITION_Y"

#define ARC4RANDOM_MAX 0x100000000

//  determine color collisions
static const uint32_t wallHitCategory = 0x1 << 0;
static const uint32_t floorHitCategory = 0x1 << 1;
static const uint32_t juggleHitCategory = 0x1 << 2;
static const uint32_t underJuggleHitCategory = 0x1 << 3;
static const uint32_t ballHitCategory = 0x1 << 4;

@interface GameBoard () <SKPhysicsContactDelegate>
{
    SKSpriteNode *nodeJuggleContainer;
    
    int score;
    BOOL failedGame;
    
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat screenMargin;
    
    CGFloat juggleHeight;
    CGFloat juggleWidth;
    
    CGFloat acceleration;
    CGFloat ballStartY;
    
    UIColor *backgroundColor;
    
    NSMutableArray *balls;
}

@property (nonatomic, strong) SKView *skView;
@property (nonatomic, strong) SKPhysicsWorld *physicsWorld;
@property (nonatomic, assign) id<GameBoardDelegate> delegate;

@property (atomic, strong) NSMutableArray *juggles;

@end

@implementation GameBoard

+ (GameBoard*)gameBoardWithRect:(CGRect)rect
                         skView:(SKView *)skView
                 skPhysicsWorls:(SKPhysicsWorld *)physicsWorld
                       delegate:(id<GameBoardDelegate>)delegate
{
    GameBoard *gameBoard = [super shapeNodeWithRect:rect];
    gameBoard.skView = skView;
    gameBoard.physicsWorld = physicsWorld;
    gameBoard.delegate = delegate;
    gameBoard.lineWidth = 0;
    gameBoard.fillColor = [UIColor clearColor];
    
    gameBoard.lineWidth = 0;
    
    [gameBoard initGame];
    
    return gameBoard;
}

- (void)startGame
{
    
}

- (void)update:(NSTimeInterval)currentTime
{
//    if (!_isRunning)
//    {
//        return;
//    }
    
    [self updateBalls];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInNode:self];
    [self addJuggleAtX:touchLocation.x];
}

- (void)initGame
{
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    score = 0;
    failedGame = NO;
    _isRunning = NO;
    
    screenWidth = self.frame.size.width;
    screenHeight = self.frame.size.height;
    screenMargin = [LayoutUtils layoutValueForConfig:kLayoutScreenMargin];
    
    juggleHeight = screenHeight * 0.035;
    juggleWidth = screenWidth * 0.28;
    
    acceleration = screenHeight * 0.0004 * -1;
    ballStartY = screenHeight * 0.9;
    
    balls = [[NSMutableArray alloc] init];
    _juggles = [[NSMutableArray alloc] init];
    
    [self initUI];
    [self addNewBallIfPossible];
}

- (void)initUI
{
    self.fillColor = [UIColor clearColor];
    
    nodeJuggleContainer = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor]
                                                       size:CGSizeMake(screenWidth, juggleHeight * 2)];
    
    nodeJuggleContainer.position = CGPointMake(screenWidth/2, screenHeight * 0.15);
    [self addChild:nodeJuggleContainer];
    
    nodeJuggleContainer.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-nodeJuggleContainer.frame.size.width/2, 0)
                                                                   toPoint:CGPointMake(nodeJuggleContainer.frame.size.width/2, 0)];
    nodeJuggleContainer.physicsBody.dynamic = YES;
    nodeJuggleContainer.physicsBody.categoryBitMask = underJuggleHitCategory;
    nodeJuggleContainer.physicsBody.collisionBitMask = 0;
    nodeJuggleContainer.physicsBody.contactTestBitMask = ballHitCategory;
    
    SKSpriteNode *nodeJuggleLine = [SKSpriteNode spriteNodeWithColor:COLOR_GAME_JUGGLE_CONTAINER
                                                                size:CGSizeMake(screenWidth, juggleHeight)];
    nodeJuggleLine.position = CGPointMake(0, (nodeJuggleContainer.frame.size.height - juggleHeight)/2);
    [nodeJuggleContainer addChild:nodeJuggleLine];
    
    //  WALLS
    SKSpriteNode *wallLeft = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(10, screenHeight * 2)];
    wallLeft.position = CGPointMake(0, screenHeight);
    [self addChild:wallLeft];
    
    wallLeft.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, -(wallLeft.size.height/2))
                                                        toPoint:CGPointMake(0, (wallLeft.size.height/2))];
    wallLeft.physicsBody.dynamic = YES;
    wallLeft.physicsBody.categoryBitMask = wallHitCategory;
    wallLeft.physicsBody.collisionBitMask = 0;
    wallLeft.physicsBody.contactTestBitMask = ballHitCategory;
    
    SKSpriteNode *wallRight = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(10, screenHeight * 2)];
    wallRight.position = CGPointMake(screenWidth, screenHeight);
    [self addChild:wallRight];
    
    wallRight.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, -(wallRight.size.height/2))
                                                         toPoint:CGPointMake(0, (wallRight.size.height/2))];
    wallRight.physicsBody.dynamic = YES;
    wallRight.physicsBody.categoryBitMask = wallHitCategory;
    wallRight.physicsBody.collisionBitMask = 0;
    wallRight.physicsBody.contactTestBitMask = ballHitCategory;
    
    //  FLOOR
    SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(screenWidth, 1)];
    floor.position = CGPointMake(screenWidth/2, 1);
    [self addChild:floor];
    
    floor.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(screenWidth * -0.5, 0)
                                                         toPoint:CGPointMake(screenWidth * 0.5, 0)];
    floor.physicsBody.dynamic = YES;
    floor.physicsBody.categoryBitMask = floorHitCategory;
    floor.physicsBody.collisionBitMask = 0;
    floor.physicsBody.contactTestBitMask = ballHitCategory;
}

- (void)addNewBallIfPossible
{
    BOOL canAdd = false;
    if (score == 0 || score == 3 || score == 10)
    {
        canAdd = true;
    }
    if (score >= 20 && score <= 50 && score % 10 == 0)
    {
        canAdd = true;
    }
    if (score > 50 && score % 50 == 0)
    {
        canAdd = true;
    }
    if (canAdd)
    {
        [self addBall];
    }
}

- (void)addBall
{
    int currentBallIndex = [[BallsUtils sharedInstance] getCurrentBallIndex];
    NSString *currentBallImage = [[BallsUtils sharedInstance] imageNameForBallAtIndex:currentBallIndex];
    Ball *ball = [Ball ballWithImageNamed:currentBallImage];
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.size.width/2];
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.categoryBitMask = ballHitCategory;
    ball.physicsBody.collisionBitMask = 0;
    ball.physicsBody.contactTestBitMask = wallHitCategory | floorHitCategory | juggleHitCategory | underJuggleHitCategory;
    ball.physicsBody.usesPreciseCollisionDetection = YES;
    
    CGFloat ballStartX = (arc4random() % (int)(screenWidth - juggleWidth)) + (juggleWidth/2);
    ball.position = CGPointMake(ballStartX, ballStartY);
    [self addChild:ball];
    
    SKAction *actionFadeIn = [SKAction fadeAlphaTo:1.0 duration:0.25];
    SKAction *actionFadeOut = [SKAction fadeAlphaTo:0.3 duration:0.25];
    SKAction *actionSequence = [SKAction sequence:@[actionFadeOut, actionFadeIn, actionFadeOut, actionFadeIn, actionFadeOut, actionFadeIn, actionFadeOut, actionFadeIn]];
    [ball runAction:actionSequence
         completion:^{
             [balls addObject:ball];
             ball.accelerationY = acceleration;
    }];
}

- (void)updateBalls
{
    for (Ball *ball in balls)
    {
        ball.dy += ball.accelerationY;

        ball.position = CGPointMake(ball.position.x + ball.dx,
                                    ball.position.y + ball.dy);
    }
}

- (void)addJuggleAtX:(CGFloat)x
{
    if (_juggles.count == 2)
    {
        SKSpriteNode *juggleNode = _juggles.firstObject;
        [juggleNode removeFromParent];
        [_juggles removeObject:_juggles.firstObject];
    }
    
    SKSpriteNode *nodeJuggle = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor]
                                                            size:CGSizeMake(juggleWidth, juggleHeight)];
    nodeJuggle.position = CGPointMake(x - (screenWidth/2), juggleHeight/2);
    [nodeJuggleContainer addChild:nodeJuggle];
    [_juggles addObject:nodeJuggle];
    
    SKShapeNode *shapeNodeJuggle = [SKShapeNode shapeNodeWithRectOfSize:nodeJuggle.size
                                                           cornerRadius:juggleHeight/2];
    shapeNodeJuggle.fillColor = COLOR_GAME_JUGGLE;
    shapeNodeJuggle.lineWidth = 0;
    shapeNodeJuggle.position = CGPointMake(0, 0);
    [nodeJuggle addChild:shapeNodeJuggle];
    
    nodeJuggle.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-juggleWidth/2, juggleHeight/2)
                                                          toPoint:CGPointMake(juggleWidth/2, juggleHeight/2)];
    nodeJuggle.physicsBody.dynamic = YES;
    nodeJuggle.physicsBody.categoryBitMask = juggleHitCategory;
    nodeJuggle.physicsBody.collisionBitMask = 0;
    nodeJuggle.physicsBody.contactTestBitMask =  ballHitCategory;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DURATION_JUGGLE_ON_SCREEN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (nodeJuggle && nodeJuggle.parent != nil)
        {
            [_juggles removeObject:nodeJuggle];
            [nodeJuggle removeFromParent];
        }
    });
}

- (void)updateBall:(Ball*)ball juggle:(SKSpriteNode*)juggle withContactPoint:(CGPoint)contactPoint
{
    CGFloat distance = screenHeight * 0.75;
    distance = distance / 30;
    
    CGFloat maxX = distance * 0.15;
    
    CGPoint pointInJuggle = [juggle convertPoint:contactPoint fromNode:self.scene];
    
    ball.dx = (pointInJuggle.x / (juggleWidth/2)) * maxX;
    ball.dy = (distance - ABS(ball.dx));
}

- (void)onGameCompleteWithBall:(Ball*)ball
{
    //  pause and hide all the balls
    SKAction *actionFadeOut = [SKAction fadeAlphaTo:0 duration:0.4];
    for (Ball *ball in balls)
    {
        ball.dx = 0;
        ball.dy = 0;
        ball.accelerationY = 0;
        
        [ball runAction:actionFadeOut];
    }
    
    //  Blink screen
    SKAction *actionBlickFinishColor = [SKAction runBlock:^{
        self.fillColor = COLOR_FINISH;
    }];
    SKAction *actionBlickCurrentColor = [SKAction runBlock:^{
        self.fillColor = backgroundColor;
    }];
    SKAction *actionPause = [SKAction waitForDuration:0.2];
    
    SKAction *sequence = [SKAction sequence:@[actionBlickFinishColor,
                                              actionPause,
                                              actionBlickCurrentColor,
                                              actionPause,
                                              actionBlickFinishColor,
                                              actionPause,
                                              actionBlickCurrentColor,
                                              actionPause,
                                              actionBlickFinishColor,
                                              actionPause,
                                              actionBlickCurrentColor,
                                              actionPause,
                                              actionBlickFinishColor]];
    [self runAction:sequence
         completion:^{
             [self.delegate gameBoardDidFinish:self withScore:score];
         }];
    
    [SoundUtils playSoundNamed:SOUND_GAME_COMPLETED inScene:self.scene];
}

#pragma mark SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    Ball *ball;
    SKSpriteNode *wall;
    if ([balls containsObject:contact.bodyA.node])
    {
        ball = (Ball*)contact.bodyA.node;
        wall = (SKSpriteNode*)contact.bodyB.node;
    }
    else
    {
        ball = (Ball*)contact.bodyB.node;
        wall = (SKSpriteNode*)contact.bodyA.node;
    }
    
    if (failedGame)
    {
        if (wall.physicsBody.categoryBitMask == floorHitCategory)
        {
            [self onGameCompleteWithBall:ball];
        }
        return;
    }
    
    if (wall.physicsBody.categoryBitMask == wallHitCategory)
    {
        ball.dx *= -1;
    }
    else if (wall.physicsBody.categoryBitMask == juggleHitCategory)
    {
        score++;
        [self.delegate gameBoardDidUpdateScore:score];
        
        [self updateBall:ball
                  juggle:wall
        withContactPoint:contact.contactPoint];
        
        [self addNewBallIfPossible];
        
        [SoundUtils playSoundNamed:SOUND_CORRECT_COLLIDE inScene:self.scene];
    }
    else if (wall.physicsBody.categoryBitMask == underJuggleHitCategory)
    {
        failedGame = YES;
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{

}


@end
