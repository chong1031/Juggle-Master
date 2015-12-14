//
//  GameScene.m
//  lock
//
//  Created by Marius Rott on 24/09/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import "GameScene.h"
#import "SettingsScene.h"
#import "FinishScene.h"
#import "ShopScene.h"
#import "GameBoard.h"

#import "configuration.h"
#import "gameConfiguration.h"

#import "Utils.h"
#import "SettingsUtils.h"
#import "SoundUtils.h"
#import "LayoutUtils.h"
#import "UserModel.h"

#import "MGButton.h"
#import "SKEase.h"

#import <Flurry-iOS-SDK/Flurry.h>

typedef enum {
    STATE_GAME_START = 1,
    STATE_GAME_PLAY
} STATE_GAME;

@interface GameScene () <GameBoardDelegate>
{
    STATE_GAME state;
    
    SKShapeNode *layerHud;
    SKShapeNode *layerGame;
    
    GameBoard *gameBoard;
    
    SKLabelNode *labelTitle;
    SKLabelNode *labelTapToStart;
    SKLabelNode *labelCurrentScore;
    
    MGButton *buttonSettings;
    MGButton *buttonShop;
    MGButton *buttonRate;
    
    SKLabelNode *labelDisableAdsPrice;
    
    SKShapeNode *nodePointsContainer;
    
    UIColor *_backgroundColor;
}

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    [self initLayers];
    [self initHud];
    [self setScore];
    [self setState:STATE_GAME_START];
    
    [[Utils sharedInstance].gameViewControllerDelegate gameShowBanner];
}

- (void)setSceneBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!gameBoard)
    {
        [self setState:STATE_GAME_PLAY];
    }
    else
    {
        [gameBoard touchesBegan:touches withEvent:event];
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    if (gameBoard)
    {
        [gameBoard update:currentTime];
    }
}

- (void)initLayers
{
    if (_backgroundColor == nil)
    {
        _backgroundColor = COLOR_START;
    }
    self.backgroundColor = _backgroundColor;
    
    layerHud = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    layerHud.fillColor = [UIColor clearColor];
    layerHud.lineWidth = 0;
    layerHud.zPosition = 10.0;
    [self addChild:layerHud];
        
    layerGame = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    layerGame.fillColor = [UIColor clearColor];
    layerGame.lineWidth = 0;
    layerGame.zPosition = 1.0;
    [self addChild:layerGame];
}

- (void)initHud
{
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    CGFloat screenMargin = [LayoutUtils layoutValueForConfig:kLayoutScreenMargin];
    
    CGFloat fontSizeTitle = [LayoutUtils layoutValueForConfig:kLayoutTitleFontSize] * self.frame.size.height;
    CGFloat fontSizeText = [LayoutUtils layoutValueForConfig:kLayoutTextFontSize] * self.frame.size.height;
    
    labelTitle = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelTitle.fontColor = COLOR_FONT;
    labelTitle.text = @"JUGGLE";
    labelTitle.fontSize = fontSizeTitle;
    labelTitle.position = CGPointMake(screenWidth * 0.5, screenHeight * 0.80);
    [layerHud addChild:labelTitle];
    
    CGFloat bannerHeight = [LayoutUtils layoutValueForConfig:kLayoutBannerHeight];
    bannerHeight = 0;
    
    buttonSettings = [MGButton buttonWithNormalImage:@"settings.png" normalSelImage:@"settings.png"];
    buttonSettings.position = CGPointMake((buttonSettings.normalImageNode.size.width/2) + screenMargin,
                                          bannerHeight + (buttonSettings.normalImageNode.size.height/2) + (screenMargin));
    [buttonSettings performOnEvent:MGButtonControlEventTouchUpInside
                         block:^{
                             [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                             SettingsScene *scene = [[SettingsScene alloc] init];
                             scene.scaleMode = SKSceneScaleModeAspectFill;
                             scene.size = self.view.bounds.size;
                             [self.view presentScene:scene];
                             [Flurry logEvent:@"GameScene - buttonSettings"];
                         }];
    [layerHud addChild:buttonSettings];
    
    buttonShop = [MGButton buttonWithNormalImage:@"shop.png" normalSelImage:@"shop.png"];
    buttonShop.position = CGPointMake(layerHud.frame.size.width - (buttonShop.normalImageNode.size.width/2) - screenMargin,
                                      bannerHeight + (buttonShop.normalImageNode.size.height/2) + (screenMargin));
    [buttonShop performOnEvent:MGButtonControlEventTouchUpInside
                            block:^{
                                [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                                ShopScene *scene = [[ShopScene alloc] init];
                                scene.scaleMode = SKSceneScaleModeAspectFill;
                                scene.size = self.view.bounds.size;
                                [self.view presentScene:scene];
                                [Flurry logEvent:@"MainMenuScene - buttonShop"];
                            }];
    [layerHud addChild:buttonShop];
    
    labelTapToStart = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelTapToStart.fontColor = COLOR_FONT;
    labelTapToStart.text = @"TAP TO START";
    labelTapToStart.fontSize = fontSizeText;
    labelTapToStart.position = CGPointMake(screenWidth * 0.5, screenHeight * 0.35);
    [layerHud addChild:labelTapToStart];
    
    labelCurrentScore = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelCurrentScore.fontColor = COLOR_FONT;
    labelCurrentScore.text = @"";
    labelCurrentScore.fontSize = fontSizeTitle;
    labelCurrentScore.position = CGPointMake(screenWidth * 0.5, screenHeight * 0.9);
    [layerHud addChild:labelCurrentScore];
    
    SKAction *actionScaleUp = [SKAction scaleTo:1.2 duration:2.0];
    SKAction *actionScaleDown = [SKAction scaleTo:1.0 duration:2.0];
    SKAction *actionSequence = [SKAction sequence:@[actionScaleUp, actionScaleDown]];
    [labelTapToStart runAction:[SKAction repeatActionForever:actionSequence]];
}

- (void)setScore
{
    if (nodePointsContainer)
    {
        [nodePointsContainer removeFromParent];
    }
    
    nodePointsContainer = [SKShapeNode shapeNodeWithRect:self.frame cornerRadius:0];
    nodePointsContainer.lineWidth = 0;
    nodePointsContainer.fillColor = [UIColor clearColor];
    nodePointsContainer.zPosition = 0;
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

- (void)initGame
{
    gameBoard = [GameBoard gameBoardWithRect:CGRectMake(0, 0, self.size.width, self.size.height)
                                      skView:self.view
                              skPhysicsWorls:self.physicsWorld
                                    delegate:self];
    gameBoard.position = CGPointMake(0, 0);
    [layerGame addChild:gameBoard];
}

- (void)initDisableAds
{
    SKShapeNode *background = [SKShapeNode shapeNodeWithRectOfSize:self.frame.size];
    background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    background.fillColor = [UIColor clearColor];
    background.strokeColor = [UIColor clearColor];
    background.userInteractionEnabled = YES;
    [layerHud addChild:background];
    
    CGFloat widthPopup = [LayoutUtils layoutValueForConfig:kLayoutSettingsPopupWidth] * self.frame.size.width;
    CGFloat screenMargin = [LayoutUtils layoutValueForConfig:kLayoutScreenMargin];
    
    SKShapeNode *nodeContent = [SKShapeNode shapeNodeWithRect:CGRectMake(widthPopup * -0.5, widthPopup * -0.5, widthPopup, widthPopup)
                                                         cornerRadius:0.05 * widthPopup];
    nodeContent.position = CGPointZero;
    nodeContent.fillColor = COLOR_SETTINGS_BACKGROUND;
    nodeContent.lineWidth = 0;
    nodeContent.zPosition = 10;
    [background addChild:nodeContent];
    
    SKLabelNode *labelDisableAds = [SKLabelNode labelNodeWithText:@"Disable Ads"];
    labelDisableAds.fontSize = widthPopup * 0.1;
    labelDisableAds.fontName = @"HelveticaNeue";
    labelDisableAds.fontColor = [UIColor blackColor];
    labelDisableAds.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    labelDisableAds.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    labelDisableAds.position = CGPointMake(0, widthPopup * 0.2);
    [nodeContent addChild:labelDisableAds];
    
    labelDisableAdsPrice = [SKLabelNode labelNodeWithText:[[Utils sharedInstance].gameViewControllerDelegate priceForDisableAds]];
    labelDisableAdsPrice.fontSize = widthPopup * 0.1;
    labelDisableAdsPrice.fontName = @"HelveticaNeue-Italic";
    labelDisableAdsPrice.fontColor = [UIColor blackColor];
    labelDisableAdsPrice.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    labelDisableAdsPrice.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    labelDisableAdsPrice.position = CGPointMake(0, 0);
    [nodeContent addChild:labelDisableAdsPrice];
    
    MGButton *buttonCheck = [MGButton buttonWithNormalImage:@"check.png" normalSelImage:@"check_sel.png"];
    buttonCheck.position = CGPointMake(0, widthPopup * -0.5 + screenMargin + (buttonCheck.normalImageNode.frame.size.height/2));
    [buttonCheck performOnEvent:MGButtonControlEventTouchUpInside
                            block:^{
                                [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                                if ([Utils sharedInstance].gameViewControllerDelegate != nil &&
                                    [[Utils sharedInstance].gameViewControllerDelegate respondsToSelector:@selector(gameDisableAds)])
                                {
                                    [[Utils sharedInstance].gameViewControllerDelegate gameDisableAds];
                                }
                                [Flurry logEvent:@"GameScene ADS - buttonCheck"];
                            }];
    [nodeContent addChild:buttonCheck];
    
    MGButton *buttonSettingsClose = [MGButton buttonWithNormalImage:@"close.png" normalSelImage:@"close_sel.png"];
    buttonSettingsClose.position = CGPointMake(widthPopup - (buttonSettingsClose.normalImageNode.size.width / 2) - (screenMargin/2) - (widthPopup/2),
                                               (widthPopup - buttonSettingsClose.normalImageNode.size.height / 2) - (screenMargin/2) - (widthPopup/2));
    [buttonSettingsClose performOnEvent:MGButtonControlEventTouchUpInside
                                  block:^{
                                      [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                                      SKAction *scaleDown = [SKEase ScaleToWithNode:nodeContent
                                                                       EaseFunction:CurveTypeBack
                                                                               Mode:EaseIn
                                                                               Time:0.2
                                                                            ToValue:0];
                                      [nodeContent runAction:scaleDown
                                                          completion:^{
                                                              [background removeFromParent];
                                                          }];
                                      [Flurry logEvent:@"GameScene ADS - buttonSettingsClose"];
                                  }];
    [nodeContent addChild:buttonSettingsClose];
    
    SKAction *scaleDown = [SKAction scaleTo:0 duration:0];
    [nodeContent runAction:scaleDown
                        completion:^{
                            SKAction *scaleUp = [SKEase ScaleToWithNode:nodeContent
                                                           EaseFunction:CurveTypeBack
                                                                   Mode:EaseOut
                                                                   Time:0.3
                                                                ToValue:1];
                            [nodeContent runAction:scaleUp];
                        }];
}


- (void)setState:(STATE_GAME)newState
{
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.2];
    
    state = newState;
    switch (state)
    {
        case STATE_GAME_START:
            break;
        case STATE_GAME_PLAY:
            [self initGame];
            [gameBoard startGame];
            
            [buttonRate runAction:fadeOut];
            [buttonSettings runAction:fadeOut];
            [buttonShop runAction:fadeOut];
            [labelTitle runAction:fadeOut];
            [labelTapToStart runAction:fadeOut];
            [nodePointsContainer runAction:fadeOut];
            break;
    }
}

#pragma mark GameBoardDelegate

- (void)gameBoardDidStart
{
    [self setState:STATE_GAME_PLAY];
}

- (void)gameBoardDidUpdateScore:(int)score
{
    labelCurrentScore.text = [NSString stringWithFormat:@"%d", score];
}

- (void)gameBoardDidFinish:(GameBoard*)board withScore:(int)score
{
    if ([Utils sharedInstance].gameViewControllerDelegate && [[Utils sharedInstance].gameViewControllerDelegate respondsToSelector:@selector(gameShowInterstitial)])
    {
        [[Utils sharedInstance].gameViewControllerDelegate gameShowInterstitial];
    }
    
    int highscore = [[UserModel sharedInstance] getHighscore].intValue;
    [[Utils sharedInstance].gameViewControllerDelegate gameGKReportScore:highscore
                                                           leaderBoardID:LEADERBOARD_ID];
    
    [[UserModel sharedInstance] updateHighscore:[NSNumber numberWithInt:score]];
    [[UserModel sharedInstance] addPoints:[NSNumber numberWithInt:score]];
    
    FinishScene *scene = [[FinishScene alloc] init];
    scene.isHighscore = score > highscore;
    scene.score = score;
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.size = self.view.bounds.size;
    [self.view presentScene:scene];
    [Flurry logEvent:@"GameScene - finishGame"];
}

#pragma mark -

- (void)skProductsLoaded:(NSNotification*)notification
{
    if (labelDisableAdsPrice)
    {
        labelDisableAdsPrice.text = [[Utils sharedInstance].gameViewControllerDelegate priceForDisableAds];
    }
}

@end
