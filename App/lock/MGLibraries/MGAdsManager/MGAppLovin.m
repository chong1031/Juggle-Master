//
//  MGAppLovin.m
//  flows
//
//  Created by Marius Rott on 16/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "MGAppLovin.h"
#import "Flurry.h"
#import "ALSdk.h"
#import "ALInterstitialAd.h"

@implementation MGAppLovin


- (id)init
{
    self = [super init];
    if (self)
    {
        [ALSdk initializeSdk];
    }
    return self;
}

- (MgAdsTypeProvider)getType
{
    return MgAdsProviderAppLovin;
}

- (void)fetchAds
{
    [[[ALSdk shared] adService] loadNextAd:[ALAdSize sizeInterstitial] andNotify: self];
}

- (BOOL)isAvailable
{
//    BOOL available = [ALInterstitialAd isReadyForDisplay];
//    return available;
    
    return self.cachedAd != nil;
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    [Flurry logEvent:@"MGAdsManager: AppLovin"];
    [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];
    
//    if([ALInterstitialAd isReadyForDisplay])
//    {
//        [ALInterstitialAd show];
//    }
}

-(void) adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    self.cachedAd = ad;
}

-(void) adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    // Ad could not be loaded (network timeout or no-fill)
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}


-(void) ad:(ALAd *) ad wasDisplayedIn: (UIView *)view
{
    
}

-(void) ad:(ALAd *) ad wasHiddenIn: (UIView *)view
{
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}

-(void) ad:(ALAd *) ad wasClickedIn: (UIView *)view
{
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}


@end
