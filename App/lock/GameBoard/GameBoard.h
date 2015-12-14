//
//  GameBoard.h
//  game
//
//  Created by Marius Rott on 26/03/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class GameBoard;

@protocol GameBoardDelegate <NSObject>

- (void)gameBoardDidUpdateScore:(int)score;
- (void)gameBoardDidFinish:(GameBoard*)board withScore:(int)score;

@end

@interface GameBoard : SKShapeNode

@property (nonatomic, assign) BOOL isRunning;

+ (GameBoard*)gameBoardWithRect:(CGRect)rect
                         skView:(SKView*)skView
                 skPhysicsWorls:(SKPhysicsWorld*)physicsWorls
                       delegate:(id<GameBoardDelegate>)delegate;

- (void)startGame;

- (void)update:(NSTimeInterval)currentTime;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end
