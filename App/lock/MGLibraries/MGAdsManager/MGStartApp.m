//
//  MGAppLovin.m
//  flows
//
//  Created by Marius Rott on 16/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "MGStartApp.h"
#import "Flurry.h"

@implementation MGStartApp

- (id)init
{
    self = [super init];
    if (self)
    {
        _isAvailable = false;
        
        STAStartAppSDK* sdk = [STAStartAppSDK sharedInstance];
        sdk.appID = MG_ADS_STARTAPP_APP_ID;
        sdk.devID = MG_ADS_STARTAPP_DEV_ID;
    }
    return self;
}

- (MgAdsTypeProvider)getType
{
    return MgAdsProviderAppLovin;
}

- (void)fetchAds
{
    self.cachedAd = [[STAStartAppAd alloc] init];
    [self.cachedAd loadAd:STAAdType_FullScreen withDelegate:self];
}

- (BOOL)isAvailable
{
    return _isAvailable;
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    [Flurry logEvent:@"MGAdsManager: StartApp"];
    [self.cachedAd showAd];
}

- (void) didLoadAd:(STAAbstractAd*)ad
{
    _isAvailable = true;
}

- (void) failedLoadAd:(STAAbstractAd*)ad withError:(NSError *)error
{
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}

- (void) didShowAd:(STAAbstractAd*)ad
{
    
}

- (void) failedShowAd:(STAAbstractAd*)ad withError:(NSError *)error
{
    
}

- (void) didCloseAd:(STAAbstractAd*)ad
{
    _isAvailable = false;
    
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}

@end
