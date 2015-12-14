//
//  MGAdsManager.h
//  MGAds
//
//  Created by Marius Rott on 11/23/12.
//  Copyright (c) 2012 Marius Rott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGConfiguration.h"

#define MGAdsManagerNotificationAdsFinishedLoading  @"kMGAdsManagerNotificationAdsFinishedLoading"
#define MGAdsManagerNotificationLoadingScreenClose  @"kMGAdsManagerNotificationLoadingScreenClose"

@protocol MGAdsManagerDelegate <NSObject>

- (void)mgAdWillDisplay;
- (void)mgAdDidDisplay;
- (void)mgAdWillClose;
- (void)mgAdDidClose;

@end

@protocol MGAdsProvider <NSObject>

//- (id)initWithType:(MgAdsTypeProvider)providerType;
- (MgAdsTypeProvider)getType;
- (void)fetchAds;
- (BOOL)isAvailable;
- (void)showAdFromViewController:(UIViewController*)viewController;

@optional
- (void)setRootView:(UIView*)rootView;
- (void)showCrossPromoAdFromViewController:(UIViewController*)viewController;

@end

@interface MGAdsManager : NSObject
{
    int _numOfDisplays;
    bool _showAdsLocked;     // don't show ads if last was in less than 30 seconds before
    BOOL _canShowCrossPromo;
}

@property (nonatomic, assign) id<MGAdsManagerDelegate> delegate;

@property (nonatomic, retain) id<MGAdsProvider> mgAdStartApp;
@property (nonatomic, retain) id<MGAdsProvider> mgAdChartboost;
@property (nonatomic, retain) id<MGAdsProvider> mgAdAppLovin;

@property (nonatomic, retain) UIView *rootView;

+ (MGAdsManager*)sharedInstance;
- (void)startAdsManager;
- (void)appDidBecomeActive;
- (void)fetchAds;
- (BOOL)isAvailable;
- (BOOL)displayAdInViewController:(UIViewController*)viewController;

- (void)showCrosspromotionInterstitialInVC:(UIViewController*)viewController;

- (id<MGAdsProvider>)getProviderForType:(MgAdsTypeProvider)providerType;

- (BOOL)isAdsEnabled;
- (void)disableAds;

- (void)unlockShowAdsAfterInterval;

@end
