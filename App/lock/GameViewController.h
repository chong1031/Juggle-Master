//
//  GameViewController.h
//  lock
//

//  Copyright (c) 2015 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

#define kGameViewControllerSKProductsLoadeddNotification @"kGameViewControllerSKProductsLoadeddNotification"

@protocol GameViewControllerDelegate <NSObject>

- (void)gameShowInterstitial;
- (void)gameShowBanner;
- (void)gameHideBanner;
- (void)gameDisableAds;
- (NSString*)priceForDisableAds;
- (void)gameRestorePurchases;
- (void)gameOpenSupportEmail;
- (void)gameOpenShareInviteOthers;
- (void)gameOpenShareScore:(int)score isHighscore:(BOOL)isHighscore;
- (void)gameOpenShareScoreFacebook:(int)score;
- (void)gameOpenShareScoreTwitter:(int)score;
- (void)gameGKReportScore:(int)score leaderBoardID:(NSString*)leaderboardID;
- (void)gameOpenGKLeaderboard;
- (void)gameOpenGKAchievements;
- (void)gamePresentRatePopup;
- (UIImage*)captureScreenImage;
- (void)shareScreenImageInActivity;

@end

@interface GameViewController : UIViewController <GameViewControllerDelegate>

@end
