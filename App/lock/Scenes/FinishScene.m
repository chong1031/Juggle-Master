//
//  FinishScene.m
//  juggle
//
//  Created by Rott Marius Gabriel on 02/11/15.
//  Copyright © 2015 mrott. All rights reserved.
//

#import "FinishScene.h"
#import "SettingsScene.h"
#import "GameScene.h"

#import "UserModel.h"
#import "Utils.h"
#import "LayoutUtils.h"
#import "configuration.h"
#import "gameConfiguration.h"

#import "MGButton.h"
#import "SoundUtils.h"
#import "SettingsUtils.h"

#import "MGVungle.h"

#import <Colours/Colours.h>
#import <Flurry-iOS-SDK/Flurry.h>

@interface FinishScene () <MGVungleDelegate>
{
    SKShapeNode *layerFinish;
    
    SKShapeNode *nodePointsContainer;
    SKShapeNode *nodeBonusContainer;
    
    MGButton *buttonVideo;
}
@end

@implementation FinishScene

- (void)didMoveToView:(SKView *)view
{
    self.backgroundColor = COLOR_START;
    [self initLayers];
    [self initLabels];
    [self initFinishButtons];
    [self setScore];
    
    [[MGVungle sharedInstance] setDelegate:self];
    if ([[MGVungle sharedInstance] isAdPlayable])
    {
        [self initVideo];
    }
}

- (void)initLayers
{
    self.backgroundColor = COLOR_FINISH;
    
    layerFinish = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, self.size.width, self.size.height)
                                    cornerRadius:0];
    layerFinish.position = CGPointMake(0, 0);
    layerFinish.fillColor = [UIColor clearColor];
    layerFinish.lineWidth = 0;
    layerFinish.zPosition = 20.0;
    [self addChild:layerFinish];
}

- (void)initLabels
{
    //  score, best score, bonus
    
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    
    CGFloat fontSizeTitle = [LayoutUtils layoutValueForConfig:kLayoutTitleFontSize] * self.frame.size.height;
    CGFloat fontSizeText = [LayoutUtils layoutValueForConfig:kLayoutTextFontSize] * self.frame.size.height;

    SKShapeNode *nodeScoreContainer = [SKShapeNode shapeNodeWithRect:CGRectMake(0,
                                                                                0,
                                                                                self.frame.size.width,
                                                                                self.frame.size.height * 0.08)
                                                        cornerRadius:0];
    nodeScoreContainer.fillColor = COLOR_LABEL_BACKGROUND;
    nodeScoreContainer.strokeColor = [UIColor clearColor];
    nodeScoreContainer.position = CGPointMake(0, screenHeight * 0.75);
    [layerFinish addChild:nodeScoreContainer];
    
    SKLabelNode *labelScore = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelScore.fontColor = COLOR_FONT;
    labelScore.text = [NSString stringWithFormat:@"%d", self.score];
    labelScore.fontSize = fontSizeTitle;
    labelScore.position = CGPointMake(screenWidth * 0.3, nodeScoreContainer.frame.size.height * 0.5 - (labelScore.frame.size.height/2));
    [nodeScoreContainer addChild:labelScore];
    
    SKLabelNode *labelHighscore = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelHighscore.fontColor = COLOR_FONT;
    labelHighscore.text = [NSString stringWithFormat:@"%d", [[UserModel sharedInstance] getHighscore].intValue];
    labelHighscore.fontSize = fontSizeTitle;
    labelHighscore.position = CGPointMake(screenWidth * 0.7, nodeScoreContainer.frame.size.height * 0.5 - (labelHighscore.frame.size.height/2));
    [nodeScoreContainer addChild:labelHighscore];
    
    SKLabelNode *labelAltScore = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelAltScore.fontColor = COLOR_FONT;
    labelAltScore.text = @"SCORE";
    labelAltScore.fontSize = fontSizeText;
    labelAltScore.position = CGPointMake(screenWidth * 0.3, screenHeight * 0.72);
    [layerFinish addChild:labelAltScore];
    
    SKLabelNode *labelAltHighscore = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelAltHighscore.fontColor = COLOR_FONT;
    labelAltHighscore.fontSize = fontSizeText;
    labelAltHighscore.position = CGPointMake(screenWidth * 0.7, screenHeight * 0.72);
    [layerFinish addChild:labelAltHighscore];
    if (self.isHighscore)
    {
        labelAltHighscore.text = @"NEW BEST!";
    }
    else
    {
        labelAltHighscore.text = @"HIGHSCORE";
    }
    
    if (self.score > 0)
    {
        [self showBonusPoints:self.score];
    }
}

- (void)showBonusPoints:(int)bonusPoints
{
    if (nodeBonusContainer && nodeBonusContainer.parent)
    {
        [nodeBonusContainer removeFromParent];
    }
    
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    
    CGFloat fontSizeScore = [LayoutUtils layoutValueForConfig:kLayoutScoreFontSize] * self.frame.size.height;
    
    nodeBonusContainer = [SKShapeNode shapeNodeWithRect:CGRectMake(0,
                                                                   0,
                                                                   self.frame.size.width,
                                                                   self.frame.size.height * 0.06)
                                           cornerRadius:0];
    nodeBonusContainer.fillColor = COLOR_LABEL_BACKGROUND;
    nodeBonusContainer.strokeColor = [UIColor clearColor];
    nodeBonusContainer.position = CGPointMake(0, screenHeight * 0.6);
    [layerFinish addChild:nodeBonusContainer];
    
    SKLabelNode *labelBonus = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelBonus.fontColor = COLOR_FONT;
    labelBonus.text = [NSString stringWithFormat:@"BONUS! +%d", bonusPoints];
    labelBonus.fontSize = fontSizeScore;
    labelBonus.position = CGPointMake(screenWidth * 0.3, nodeBonusContainer.frame.size.height * 0.5 - (labelBonus.frame.size.height/2));
    [nodeBonusContainer addChild:labelBonus];
    
    SKSpriteNode *nodeDiamond = [SKSpriteNode spriteNodeWithImageNamed:@"diamond.png"];
    [nodeBonusContainer addChild:nodeDiamond];
    
    labelBonus.position = CGPointMake((nodeBonusContainer.frame.size.width - nodeDiamond.frame.size.width)/2,
                                      (nodeBonusContainer.frame.size.height - labelBonus.frame.size.height)/2);
    nodeDiamond.position = CGPointMake(labelBonus.position.x + (labelBonus.frame.size.width/2) + (nodeDiamond.frame.size.width/2),
                                       nodeBonusContainer.frame.size.height/2);
}

- (void)initFinishButtons
{
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    CGFloat screenMargin = [LayoutUtils layoutValueForConfig:kLayoutScreenMargin];
    
    MGButton *buttonDisableAds = [MGButton buttonWithNormalImage:@"disableAds.png"
                                                  normalSelImage:@"disableAds.png"];
    buttonDisableAds.position = CGPointMake(screenWidth * 0.35,
                                        screenHeight * 0.5);
    [buttonDisableAds performOnEvent:MGButtonControlEventTouchUpInside
                           block:^{
                               [[Utils sharedInstance].gameViewControllerDelegate gameDisableAds];
                               [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                               [Flurry logEvent:@"GameScene - buttonDisableAds"];
                           }];
    [layerFinish addChild:buttonDisableAds];
    
    
    MGButton *buttonShare = [MGButton buttonWithNormalImage:@"share.png" normalSelImage:@"share.png"];
    buttonShare.position = CGPointMake(screenWidth * 0.65,
                                       screenHeight * 0.5);
    [buttonShare performOnEvent:MGButtonControlEventTouchUpInside
                              block:^{
                                  [[Utils sharedInstance].gameViewControllerDelegate shareScreenImageInActivity];
                                  [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                                  [Flurry logEvent:@"MainMenuScene - buttonRate"];
                              }];
    [layerFinish addChild:buttonShare];
    
    
    MGButton *buttonSettings = [MGButton buttonWithNormalImage:@"settings.png"
                                                  normalSelImage:@"settings.png"];
    buttonSettings.position = CGPointMake(screenWidth * 0.2,
                                            screenHeight * 0.35);
    [buttonSettings performOnEvent:MGButtonControlEventTouchUpInside
                               block:^{
                                   SettingsScene *scene = [[SettingsScene alloc] init];
                                   scene.scaleMode = SKSceneScaleModeAspectFill;
                                   scene.size = self.view.bounds.size;
                                   [self.view presentScene:scene];
                                   [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                                   [Flurry logEvent:@"GameScene - buttonSettings"];
                               }];
    [layerFinish addChild:buttonSettings];
    
    
    MGButton *buttonAchievements = [MGButton buttonWithNormalImage:@"achievement.png" normalSelImage:@"achievement.png"];
    buttonAchievements.position = CGPointMake(screenWidth * 0.8,
                                       screenHeight * 0.35);
    [buttonAchievements performOnEvent:MGButtonControlEventTouchUpInside
                          block:^{
                              [[Utils sharedInstance].gameViewControllerDelegate gameOpenGKAchievements];
                              [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                              [Flurry logEvent:@"MainMenuScene - buttonRate"];
                          }];
    [layerFinish addChild:buttonAchievements];
    
    
    MGButton *buttonRate = [MGButton buttonWithNormalImage:@"rate.png"
                                            normalSelImage:@"rate.png"];
    buttonRate.position = CGPointMake(screenWidth * 0.25,
                                            screenHeight * 0.2);
    [buttonRate performOnEvent:MGButtonControlEventTouchUpInside
                               block:^{
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GAME_APP_STORE_PAGE]];
                                   [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                                   [Flurry logEvent:@"GameScene - buttonDisableAds" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:buttonRate.selected], @"soundOn", nil]];
                               }];
    [layerFinish addChild:buttonRate];
    
    
    MGButton *buttonLeaderboard = [MGButton buttonWithNormalImage:@"leaderboard.png" normalSelImage:@"leaderboard.png"];
    buttonLeaderboard.position = CGPointMake(screenWidth * 0.75,
                                             screenHeight * 0.2);
    [buttonLeaderboard performOnEvent:MGButtonControlEventTouchUpInside
                          block:^{
                              [[Utils sharedInstance].gameViewControllerDelegate gameOpenGKLeaderboard];
                              [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                              [Flurry logEvent:@"MainMenuScene - buttonRate"];
                          }];
    [layerFinish addChild:buttonLeaderboard];
    
    
    
    MGButton *buttonPlay = [MGButton buttonWithNormalImage:@"play.png" normalSelImage:@"play.png"];
    buttonPlay.position = CGPointMake(screenWidth * 0.5,
                                      screenHeight * 0.15);
    [buttonPlay performOnEvent:MGButtonControlEventTouchUpInside
                                     block:^{
                                         [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                                         GameScene *scene = [[GameScene alloc] init];
                                         scene.scaleMode = SKSceneScaleModeAspectFill;
                                         scene.size = self.view.bounds.size;
                                         [scene setSceneBackgroundColor:[[Utils randomColor] lighten:0.5]];
                                         [self.view presentScene:scene];
                                         [Flurry logEvent:@"FinishScene - buttonPlay"];
                                     }];
    [layerFinish addChild:buttonPlay];
}

- (void)initVideo
{
    if (buttonVideo)
    {
        return;
    }
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;

    buttonVideo = [MGButton buttonWithNormalImage:@"video.png" normalSelImage:@"video.png"];
    buttonVideo.position = CGPointMake(screenWidth * 0.5,
                                       screenHeight * 0.35);
    [buttonVideo performOnEvent:MGButtonControlEventTouchUpInside
                         block:^{
                             [[MGVungle sharedInstance] openIncentivizedAdInViewController:[Utils sharedInstance].viewController];
                             [self removeVideo];
                             [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                             [Flurry logEvent:@"MainMenuScene - buttonVideo"];
                         }];
    [layerFinish addChild:buttonVideo];
    
    SKAction *actionRotateHalfLeft = [SKAction rotateByAngle:M_PI_4/4 duration:0.3];
    SKAction *actionRotateRight = [SKAction rotateByAngle:-M_PI_4/2 duration:0.6];
    SKAction *sequence = [SKAction sequence:@[actionRotateHalfLeft, actionRotateRight, actionRotateHalfLeft]];
    [buttonVideo runAction:[SKAction repeatActionForever:sequence]];
}

- (void)removeVideo
{
    [buttonVideo removeFromParent];
    buttonVideo = nil;
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
    [self addChild:nodePointsContainer];
    
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    CGFloat screenMargin = [LayoutUtils layoutValueForConfig:kLayoutScreenMargin];
    
    SKSpriteNode *nodeDiamond = [SKSpriteNode spriteNodeWithImageNamed:@"diamond.png"];
    nodeDiamond.position = CGPointMake(screenWidth - (nodeDiamond.size.height/2) - screenMargin,
                                       screenHeight - (nodeDiamond.size.height/2) - screenMargin);
    [nodePointsContainer addChild:nodeDiamond];
    
    SKLabelNode *labelPoints = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelPoints.fontColor = COLOR_FONT;
    labelPoints.text = [NSString stringWithFormat:@"%d", [[UserModel sharedInstance] getPoints].intValue];
    labelPoints.fontSize = [LayoutUtils layoutValueForConfig:kLayoutScoreFontSize] * self.frame.size.height;
    labelPoints.position = CGPointMake(nodeDiamond.position.x - (nodeDiamond.frame.size.width/2) - (screenMargin/2) - (labelPoints.frame.size.width/2),
                                      nodeDiamond.position.y - (labelPoints.frame.size.height/2));
    [nodePointsContainer addChild:labelPoints];
}

#pragma mark MGVungleDelegate

- (void)mgVungleDelegateAdVisibilityChanged:(BOOL)isAdPlayable
{
    NSLog(@"Video Changed: %d", isAdPlayable);
    if (isAdPlayable)
    {
        [self initVideo];
    }
    else
    {
        [self removeVideo];
    }
}

- (void)mgVungleDelegateAllocateReward
{
    [[UserModel sharedInstance] addPoints:[NSNumber numberWithInt:VUNGLE_BONUS_POINTS]];
    [self setScore];
    
    [self showBonusPoints:VUNGLE_BONUS_POINTS];
}

@end
