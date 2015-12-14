//
//  GameViewController.m
//  game
//
//  Created by Marius Rott on 04/03/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "FinishScene.h"
#import "gameConfiguration.h"
#import "configuration.h"
#import "Utils.h"

#import "MGAdsManager.h"
#import "MGIAPHelper.h"

#import <MessageUI/MessageUI.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Reachability/Reachability.h>
#import <GameKit/GameKit.h>
#import <iRate/iRate.h>
#import <Social/Social.h>

@interface GameViewController () <MFMailComposeViewControllerDelegate, GKGameCenterControllerDelegate>
{
    GADBannerView *bannerView;
    
    NSArray *_arraySKProducts;
    BOOL _gameCenterEnabled;
    NSString *_leaderboardIdentifier;
}

- (void)notificationProductPurchased:(NSNotification *)notification;
- (void)notificationProductPurchaseFailed:(NSNotification *)notification;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
//        skView.showsFPS = YES;
//        skView.showsNodeCount = YES;
//     Sprite Kit applies additional optimizations to improve rendering performance
    skView.ignoresSiblingOrder = NO;
//        skView.showsPhysics = YES;
    
    [Utils sharedInstance].gameViewControllerDelegate = self;
    [Utils sharedInstance].viewController = self;
    
    GameScene *scene = [[GameScene alloc] init];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.size = self.view.bounds.size;
    [scene setBackgroundColor:COLOR_START];
    // Present the scene.
    [skView presentScene:scene];
    
    [self authenticateLocalPlayer];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationProductPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationProductPurchaseFailed:)
                                                 name:IAPHelperProductPurchaseFailedNotification
                                               object:nil];
    
    [[MGAdsManager sharedInstance] showCrosspromotionInterstitialInVC:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPHelperProductPurchasedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPHelperProductPurchaseFailedNotification
                                                  object:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark GameViewControllerDelegate

- (void)gameShowInterstitial
{
    [[MGAdsManager sharedInstance] displayAdInViewController:self];
}

- (void)gameShowBanner
{
//    [self configureBannerView];
}

- (void)gameHideBanner
{
    if (bannerView)
    {
        [bannerView removeFromSuperview];
        bannerView.delegate = nil;
        bannerView = nil;
    }
    NSLog(@"done");
}

- (void)gameDisableAds
{
    [[MGIAPHelper sharedInstance] buyProductIdentifier:STORE_BUNDLE_IN_APP_DISABLE_ADS
                                 withCompletionHandler:^(BOOL succceded) {
                                     if (!succceded)
                                     {
                                         [self notificationProductPurchaseFailed:nil];
                                     }
                                 }];
}

- (void)gameRestorePurchases
{
    [[MGIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)gameOpenSupportEmail
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:SETTINGS_SUPPORT_EMAIL];
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *model = [currentDevice model];
    NSString *systemVersion = [currentDevice systemVersion];
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [locale localeIdentifier];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *emailBody = [NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\nApp Name: %@ \nModel: %@ \nSystem Version: %@ \nLanguage: %@ \nCountry: %@ \nApp Version: %@", appName, model, systemVersion, language, country, appVersion];
    
    [picker setToRecipients:toRecipients];
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:picker
                       animated:YES
                     completion:^{
                         
                     }];
}

- (void)gameOpenShareInviteOthers
{
    [GameViewController shareText:@"Come and join me on 9 blocks game. You will improve your puzzle solving skills!"
                         andImage:[UIImage imageNamed:@"logo.png"]
                           andUrl:[NSURL URLWithString:GAME_APP_STORE_PAGE]
                 inViewController:self];
}

- (void)gameOpenShareScore:(int)score isHighscore:(BOOL)isHighscore
{
    NSString *text;
    if (isHighscore)
    {
        text = [NSString stringWithFormat:@"Check my new bestscore of %d points in 9 blocks. Can you beat this?", score];
    }
    else
    {
        text = [NSString stringWithFormat:@"I just scored %d points in 9 blocks. Can you beat this?", score];
    }
    [GameViewController shareText:text
                         andImage:[UIImage imageNamed:@"logo_big.png"]
                           andUrl:[NSURL URLWithString:GAME_APP_STORE_PAGE]
                 inViewController:self];
}

- (void)gameOpenShareScoreFacebook:(int)score
{
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result)
        {
            [fbController dismissViewControllerAnimated:YES completion:nil];
            switch(result){
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Cancelled.....");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Posted....");
                    break;
            }};
        
        [fbController setInitialText:@"Come and join me on Open the Lock. You'll become addicted to it!"];
        [fbController addURL:[NSURL URLWithString:GAME_APP_STORE_PAGE]];
        [fbController addImage:[UIImage imageNamed:@"Logo.png"]];
        
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in error"
                                                                       message:@"Please sign on Facebook in your device settings in before!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [alert dismissViewControllerAnimated:YES
                                                                              completion:nil];
                                                }]];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }
}

- (void)gameOpenShareScoreTwitter:(int)score
{
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result)
        {
            [fbController dismissViewControllerAnimated:YES completion:nil];
            switch(result){
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Cancelled.....");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Posted....");
                    break;
            }};
        
        [fbController setInitialText:@"Come and join me on Open the Lock. You'll become addicted to it!"];
        [fbController addURL:[NSURL URLWithString:GAME_APP_STORE_PAGE]];
        [fbController addImage:[UIImage imageNamed:@"Logo.png"]];
        
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in error"
                                                                       message:@"Please sign on Twitter in your device settings in before!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [alert dismissViewControllerAnimated:YES
                                                                              completion:nil];
                                                }]];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }
}

- (void)gameGKReportScore:(int)score leaderBoardID:(NSString *)leaderboardID
{
    if (!_gameCenterEnabled)
    {
        return;
    }
    GKScore *gkScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardID];
    gkScore.value = score;
    
    [GKScore reportScores:@[gkScore] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void)gameOpenGKLeaderboard
{
    if (_gameCenterEnabled)
    {
        GKGameCenterViewController *viewController = [[GKGameCenterViewController alloc] init];
        viewController.gameCenterDelegate = self;
        
        viewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        viewController.leaderboardIdentifier = _leaderboardIdentifier;
        
        [viewController popViewControllerAnimated:NO];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else
    {
        [self authenticateLocalPlayer];
    }
}

- (void)gameOpenGKAchievements
{
    if (_gameCenterEnabled)
    {
        GKGameCenterViewController *viewController = [[GKGameCenterViewController alloc] init];
        viewController.gameCenterDelegate = self;
        
        viewController.viewState = GKGameCenterViewControllerStateAchievements;
        
        [viewController popViewControllerAnimated:NO];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else
    {
        [self authenticateLocalPlayer];
    }
}

- (void)gamePresentRatePopup
{
//    NSString *appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Like %@?", appName]
//                                                                   message:@"Tell everyone and write a 5 stars review!"
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Next time"
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction * _Nonnull action) {
//                                                       [alert dismissViewControllerAnimated:YES
//                                                                                 completion:nil];
//                                                   }];
//    [alert addAction:actionCancel];
//    
//    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK"
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction * _Nonnull action) {
//                                                       [alert dismissViewControllerAnimated:YES
//                                                                                 completion:nil];
//                                                       
//                                                       [[iRate sharedInstance]]
//                                                   }];
//    [alert addAction:actionOK];
    
    [[iRate sharedInstance] promptForRating];
}

- (UIImage*)captureScreenImage
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

- (void)shareScreenImageInActivity
{
    NSString *textToShare = SHARE_TEXT;
    NSURL *myWebsite = [NSURL URLWithString:SHARE_URL];
    UIImage *imageCapture = [self captureScreenImage];
    
    NSArray *objectsToShare = @[textToShare, myWebsite, imageCapture];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)])
    {
        activityVC.popoverPresentationController.sourceView = self.view;
    }
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)notificationProductPurchased:(NSNotification *)notification
{
    [[MGAdsManager sharedInstance] disableAds];
    [self gameHideBanner];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Thank you"
                                                                   message:@"You successfully purchased this item. The ads are now disabled."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [alert dismissViewControllerAnimated:YES
                                                                          completion:nil];
                                            }]];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (void)notificationProductPurchaseFailed:(NSNotification *)notification
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Purchase error"
                                                                   message:@"There was an error completing your purchase. Please try again later!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [alert dismissViewControllerAnimated:YES
                                                                          completion:nil];
                                            }]];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

+ (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url inViewController:(UIViewController*)viewController
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [viewController presentViewController:activityController animated:YES completion:nil];
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}

#pragma mark GKGameCenterControllerDelegate

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
