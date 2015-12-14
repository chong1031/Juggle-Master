//
//  SettingsScene.m
//  juggle
//
//  Created by Rott Marius Gabriel on 02/11/15.
//  Copyright © 2015 mrott. All rights reserved.
//

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

#import <Flurry-iOS-SDK/Flurry.h>

@interface SettingsScene ()
{
    SKShapeNode *layerSettings;
    
    SKShapeNode *nodePointsContainer;
}
@end

@implementation SettingsScene

- (void)didMoveToView:(SKView *)view
{
    self.backgroundColor = COLOR_START;
    [self initLayers];
    [self initSettings];
    [self setScore];
}

- (void)initLayers
{
    layerSettings = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, self.size.width, self.size.height)
                                      cornerRadius:0];
    layerSettings.position = CGPointMake(0, 0);
    layerSettings.fillColor = [UIColor clearColor];
    layerSettings.strokeColor = [UIColor clearColor];
    layerSettings.zPosition = 1;
    [self addChild:layerSettings];
}


- (void)initSettings
{
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    CGFloat screenMargin = [LayoutUtils layoutValueForConfig:kLayoutScreenMargin];
    
    CGFloat fontSizeText = [LayoutUtils layoutValueForConfig:kLayoutTextFontSize] * self.frame.size.height;
    
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
                                 [Flurry logEvent:@"SettingsScene - buttonClose"];
                             }];
    [layerSettings addChild:buttonClose];
    
    SKLabelNode *labelSettings = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelSettings.fontColor = COLOR_FONT;
    labelSettings.text = @"SETTINGS";
    labelSettings.fontSize = [LayoutUtils layoutValueForConfig:kLayoutTitleFontSize] * self.frame.size.height;
    labelSettings.position = CGPointMake(screenWidth * 0.5, screenHeight * 0.80);
    [layerSettings addChild:labelSettings];
    
    MGButton *buttonSounds = [MGButton buttonWithNormalImage:@"soundOff.png"
                                              normalSelImage:@"soundOff.png"
                                               selectedImage:@"soundOn.png"
                                            selectedSelImage:@"soundOn.png"];
    buttonSounds.position = CGPointMake(screenWidth * 0.30,
                                        screenHeight * 0.6);
    buttonSounds.selected = [[SettingsUtils sharedInstance] soundIsOn];
    [buttonSounds performOnEvent:MGButtonControlEventTouchUpInside
                           block:^{
                               [[SettingsUtils sharedInstance] setSoundOn:buttonSounds.selected];
                               [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                               [Flurry logEvent:@"GameScene - buttonSounds" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:buttonSounds.selected], @"soundOn", nil]];
                           }];
    [layerSettings addChild:buttonSounds];
    
    SKLabelNode *labelSounds = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelSounds.fontColor = COLOR_FONT;
    labelSounds.text = @"SOUNDS";
    labelSounds.fontSize = fontSizeText;
    labelSounds.position = CGPointMake(screenWidth * 0.3, screenHeight * 0.52 - (labelSounds.frame.size.height/2));
    [layerSettings addChild:labelSounds];
    
    MGButton *buttonMoreGames = [MGButton buttonWithNormalImage:@"moregames.png" normalSelImage:@"moregames.png"];
    buttonMoreGames.position = CGPointMake(screenWidth * 0.7,
                                           screenHeight * 0.6);
    [buttonMoreGames performOnEvent:MGButtonControlEventTouchUpInside
                            block:^{
                                [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:DEVELOPER_APP_STORE_PAGE]];
                                [Flurry logEvent:@"MainMenuScene - buttonRate"];
                            }];
    [layerSettings addChild:buttonMoreGames];
    
    SKLabelNode *labelMoreGames = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelMoreGames.fontColor = COLOR_FONT;
    labelMoreGames.text = @"MORE GAMES";
    labelMoreGames.fontSize = fontSizeText;
    labelMoreGames.position = CGPointMake(screenWidth * 0.7, screenHeight * 0.52 - (labelMoreGames.frame.size.height/2));
    [layerSettings addChild:labelMoreGames];
    
    MGButton *buttonRestorePurchases = [MGButton buttonWithNormalImage:@"restore.png" normalSelImage:@"restore.png"];
    buttonRestorePurchases.position = CGPointMake(screenWidth * 0.5,
                                                  screenHeight * 0.3);
    [buttonRestorePurchases performOnEvent:MGButtonControlEventTouchUpInside
                                     block:^{
                                         [SoundUtils playSoundNamed:SOUND_BUTTON_TAP inScene:self];
                                         if ([Utils sharedInstance].gameViewControllerDelegate != nil && [[Utils sharedInstance].gameViewControllerDelegate respondsToSelector:@selector(gameRestorePurchases)])
                                         {
                                             [[Utils sharedInstance].gameViewControllerDelegate gameRestorePurchases];
                                         }
                                         [Flurry logEvent:@"MainMenuScene - buttonRestore"];
                                     }];
    [layerSettings addChild:buttonRestorePurchases];
    
    SKLabelNode *labelRestore = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelRestore.fontColor = COLOR_FONT;
    labelRestore.text = @"RESTORE IN APPS";
    labelRestore.fontSize = fontSizeText;
    labelRestore.position = CGPointMake(screenWidth * 0.5, screenHeight * 0.22 - (labelRestore.frame.size.height/2));
    [layerSettings addChild:labelRestore];
    
    SKLabelNode *labelCredits = [SKLabelNode labelNodeWithFontNamed:@"ProximaNova-Regular"];
    labelCredits.fontColor = COLOR_FONT;
    labelCredits.text = @"BY BIG APP COMPANY";
    labelCredits.fontSize = [LayoutUtils layoutValueForConfig:kLayoutTextFontSize] * self.frame.size.height;
    labelCredits.position = CGPointMake(screenWidth * 0.5, screenMargin + (labelCredits.frame.size.height/2));
    [layerSettings addChild:labelCredits];
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

@end
