//
//  SettingsScene.m
//  juggle
//
//  Created by Rott Marius Gabriel on 02/11/15.
//  Copyright © 2015 mrott. All rights reserved.
//

#import "ShopScene.h"
#import "GameScene.h"

#import "Utils.h"
#import "BallsUtils.h"
#import "UserModel.h"
#import "LayoutUtils.h"
#import "configuration.h"
#import "gameConfiguration.h"

#import "MGButton.h"
#import "MGHoverColorButton.h"
#import "SoundUtils.h"
#import "SettingsUtils.h"

#import <Flurry-iOS-SDK/Flurry.h>
#import <INSpriteKit/INSpriteKit.h>

@interface ShopScene () <INSKScrollNodeDelegate>
{
    SKShapeNode *layerShop;
    
    SKShapeNode *nodePointsContainer;
    INSKScrollNode *scrollNode;
}
@end

@implementation ShopScene

- (void)didMoveToView:(SKView *)view
{
    self.backgroundColor = COLOR_START;
    [self initLayers];
    [self initShop];
    [self initScrollView];
    [self setScore];
}

- (void)initLayers
{
    layerShop = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, self.size.width, self.size.height)
                                  cornerRadius:0];
    layerShop.position = CGPointMake(0, 0);
    layerShop.fillColor = [UIColor clearColor];
    layerShop.strokeColor = [UIColor clearColor];
    layerShop.zPosition = 1;
    [self addChild:layerShop];
}


- (void)initShop
{
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    CGFloat screenMargin = [LayoutUtils layoutValueForConfig:kLayoutScreenMargin];
    
    MGButton *buttonClose = [MGButton buttonWithNormalImage:@"close.png" normalSelImage:@"close.png"];
    buttonClose.position = CGPointMake(screenMargin + (buttonClose.normalImageNode.size.width/2),
                                       screenHeight - (buttonClose.normalImageNode.size.height/2) - screenMargin);
    [buttonClose performOnEvent:MGButtonControlEventTouchUpInside
                          block:^{
                              [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                              GameScene *scene = [[GameScene alloc] init];
                              scene.scaleMode = SKSceneScaleModeAspectFill;
                              scene.size = self.view.bounds.size;
                              [scene setBackgroundColor:COLOR_START];
                              [self.view presentScene:scene];
                              [Flurry logEvent:@"ShopScene - buttonClose"];
                          }];
    [layerShop addChild:buttonClose];
    
    SKLabelNode *labelSettings = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelSettings.fontColor = COLOR_FONT;
    labelSettings.text = @"SHOP";
    labelSettings.fontSize = [LayoutUtils layoutValueForConfig:kLayoutTitleFontSize] * self.frame.size.height;
    labelSettings.position = CGPointMake(screenWidth * 0.5, screenHeight * 0.80);
    [layerShop addChild:labelSettings];
}

- (void)setScore
{
    if (nodePointsContainer)
    {
        [nodePointsContainer removeFromParent];
    }
    
    nodePointsContainer = [SKShapeNode shapeNodeWithRect:self.frame cornerRadius:0];
    nodePointsContainer.zPosition = 0;
    nodePointsContainer.lineWidth = 0;
    [self addChild:nodePointsContainer];
    
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    CGFloat screenMargin = [LayoutUtils layoutValueForConfig:kLayoutScreenMargin];
    
    SKSpriteNode *nodeDiamond = [SKSpriteNode spriteNodeWithImageNamed:@"diamond.png"];
    nodeDiamond.position = CGPointMake(screenWidth - (nodeDiamond.size.height/2) - screenMargin,
                                       screenHeight - (nodeDiamond.size.height/2) - screenMargin);
    [nodePointsContainer addChild:nodeDiamond];
    
    SKLabelNode *labelScore = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelScore.fontColor = COLOR_FONT;
    labelScore.text = [NSString stringWithFormat:@"%d", [[UserModel sharedInstance] getPoints].intValue];
    labelScore.fontSize = [LayoutUtils layoutValueForConfig:kLayoutScoreFontSize] * self.frame.size.height;
    labelScore.position = CGPointMake(nodeDiamond.position.x - (nodeDiamond.frame.size.width/2) - (screenMargin/2) - (labelScore.frame.size.width/2),
                                      nodeDiamond.position.y - (labelScore.frame.size.height/2));
    [nodePointsContainer addChild:labelScore];
}



- (void)initScrollView
{
    CGFloat screenMargin = [LayoutUtils layoutValueForConfig:kLayoutScreenMargin];
    NSUInteger ballCount = [[BallsUtils sharedInstance] numberOfBalls];
    NSUInteger rows = ballCount/2;
    
    CGFloat scrollWidth = self.frame.size.width * 0.75;
    CGFloat scrollHeight = self.frame.size.height * 0.7;
    CGFloat cellWidth = (scrollWidth - screenMargin)/2;
    CGFloat cellHeight = [LayoutUtils layoutValueForConfig:kLayoutShopCellHeight];
    CGFloat contentHeight = (cellHeight + screenMargin) * rows;
    
    // Create scroll node
    scrollNode = [INSKScrollNode scrollNodeWithSize:CGSizeMake(scrollWidth, scrollHeight)];
    scrollNode.position = CGPointMake((self.frame.size.width - scrollWidth)/2, scrollHeight + screenMargin);
    scrollNode.scrollDelegate = self;
    scrollNode.clipContent = YES;
    [layerShop addChild:scrollNode];
    
    // Additional set up
    scrollNode.scrollBackgroundNode.color = [SKColor clearColor];
    scrollNode.decelerationMode = INSKScrollNodeDecelerationModeDecelerate;
    scrollNode.scrollContentSize = CGSizeMake(scrollWidth, contentHeight);
    
    // Set content size and position
    //    scrollNode.scrollContentPosition = CGPointMake(-(scrollNode.scrollContentSize.width - scrollNode.scrollNodeSize.width) / 2, (scrollNode.scrollContentSize.height - scrollNode.scrollNodeSize.height) / 2);
    
    // Add content to the scroll node
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:1 green:1 blue:1 alpha:0.0] size:scrollNode.scrollContentSize];
    background.position = CGPointMake(background.size.width/2, -background.size.height/2);
    [scrollNode.scrollContentNode addChild:background];
    
    SKSpriteNode *nodeDiamond = [SKSpriteNode spriteNodeWithImageNamed:@"diamond.png"];
    nodeDiamond.position = CGPointMake(50, 50);
    [scrollNode.scrollContentNode addChild:nodeDiamond];
    
    for (int i = 0; i < ballCount; i++)
    {
        CGFloat x;
        CGFloat y = (((i / 2) * cellHeight) + (((i / 2) - 1) * screenMargin)) * -1 - cellHeight - screenMargin;
        if (i % 2 == 0)
        {
            x = 0;
        }
        else
        {
            x = cellWidth + screenMargin;
        }
        
        CGFloat fontSizeScore = [LayoutUtils layoutValueForConfig:kLayoutScoreFontSize] * self.frame.size.height;
        
        SKShapeNode *nodeBall = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, cellWidth, cellHeight)
                                                  cornerRadius:0];
        nodeBall.position = CGPointMake(x, y);
        nodeBall.lineWidth = 1.0;
        [scrollNode.scrollContentNode addChild:nodeBall];
        
        if ([[BallsUtils sharedInstance] isBallPurchasedWithIndex:i])
        {
            nodeBall.fillColor = COLOR_SHOP_CELL_PURCHASED;
        }
        else
        {
            nodeBall.fillColor = COLOR_SHOP_CELL_NOT_PURCHASED;
        }
        
        int currentBallIndex = [[BallsUtils sharedInstance] getCurrentBallIndex];
        if (i == currentBallIndex)
        {
            nodeBall.strokeColor = COLOR_SHOP_CELL_PURCHASED_LINE;
        }
        else
        {
            nodeBall.strokeColor = [UIColor clearColor];
        }
        
        if (![[BallsUtils sharedInstance] isBallPurchasedWithIndex:i])
        {
            SKLabelNode *labelBonus = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
            labelBonus.fontColor = COLOR_FONT;
            labelBonus.text = [NSString stringWithFormat:@"%d", [[BallsUtils sharedInstance] priceForBallAtIndex:i]];
            labelBonus.fontSize = fontSizeScore;
            [nodeBall addChild:labelBonus];
            
            SKSpriteNode *nodeDiamond = [SKSpriteNode spriteNodeWithImageNamed:@"diamond.png"];
            [nodeBall addChild:nodeDiamond];
            
            labelBonus.position = CGPointMake((nodeBall.frame.size.width - nodeDiamond.frame.size.width)/2,
                                              (nodeBall.frame.size.height - labelBonus.frame.size.height)/2);
            nodeDiamond.position = CGPointMake(labelBonus.position.x + (labelBonus.frame.size.width/2) + (nodeDiamond.frame.size.width/2),
                                               nodeBall.frame.size.height/2);
        }
        else
        {
//            UIImage
            SKSpriteNode *nodeImage = [SKSpriteNode spriteNodeWithImageNamed:[[BallsUtils sharedInstance] imageNameForBallAtIndex:i]];
            [nodeBall addChild:nodeImage];
            nodeImage.position = CGPointMake(nodeBall.frame.size.width/2,
                                             nodeBall.frame.size.height/2);
        }
        
        MGHoverColorButton *buttonBall = [MGHoverColorButton buttonNodeWithRectOfSize:CGSizeMake(cellWidth, cellHeight)
                                                                         cornerRadius:0];
        [buttonBall setColor:[UIColor clearColor]];
        buttonBall.position = CGPointMake(nodeBall.frame.size.width/2,
                                          nodeBall.frame.size.height/2);
        
        [buttonBall performOnEvent:AGButtonControlEventTouchUpInside
                             block:^{
                                 [self selectBallWithIndex:i];
                                 [Flurry logEvent:@"Shop: Button Ball"];
                             }];
        [nodeBall addChild:buttonBall];
    }
}

- (void)selectBallWithIndex:(int)index
{
    if ([[BallsUtils sharedInstance] isBallPurchasedWithIndex:index])
    {
        [[BallsUtils sharedInstance] setCurrentBallWithIndex:index];
        [scrollNode removeFromParent];
        scrollNode = nil;
        [self initScrollView];
    }
    else
    {
        int points = [[UserModel sharedInstance] getPoints].intValue;
        int ballPrice = [[BallsUtils sharedInstance] priceForBallAtIndex:index];
        if (points >= ballPrice)
        {
            [[BallsUtils sharedInstance] purchaseBallWithIndex:index];
            [[BallsUtils sharedInstance] setCurrentBallWithIndex:index];
            [[UserModel sharedInstance] subtractPoints:[NSNumber numberWithInt:ballPrice]];
            
            [self setScore];
            [scrollNode removeFromParent];
            scrollNode = nil;
            [self initScrollView];
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Points"
                                                                                     message:@"You don't have enough points"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  
                                                              }]];
            [[Utils sharedInstance].viewController presentViewController:alertController
                                                                animated:YES
                                                              completion:nil];
        }
    }
}

@end
