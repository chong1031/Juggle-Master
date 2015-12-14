//
//  MGVungle.m
//  lock
//
//  Created by Rott Marius Gabriel on 05/11/15.
//  Copyright © 2015 mrott. All rights reserved.
//

#import "MGVungle.h"

#import "configuration.h"

#import <VungleSDK/VungleSDK.h>

@interface MGVungle () <VungleSDKDelegate>
{
    bool _showAdsLocked;     // don't show ads if last was in less than 30 seconds before
}

@property (nonatomic, assign) id<MGVungleDelegate> delegate;

@end

@implementation MGVungle

+ (MGVungle *)sharedInstance
{
    static MGVungle *sharedInstance;
    if (sharedInstance == nil)
    {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

- (BOOL)isAdPlayable
{
    if (_showAdsLocked)
    {
        return NO;
    }
    VungleSDK* sdk = [VungleSDK sharedSDK];
    return [sdk isAdPlayable];
}

- (void)startMGVungle
{
    VungleSDK* sdk = [VungleSDK sharedSDK];
    [sdk startWithAppId:@"Test_iOS"]; //VUNGLE_APP_ID];
    [sdk setDelegate:self];
}

- (void)openIncentivizedAdInViewController:(UIViewController *)viewController
{
    VungleSDK* sdk = [VungleSDK sharedSDK];
    NSError *error;
    
    // Dict to set custom ad options
    NSDictionary* options = @{VunglePlayAdOptionKeyIncentivized: @YES,
                              VunglePlayAdOptionKeyIncentivizedAlertBodyText : @"If the video isn't completed you won't get your reward! Are you sure you want to close early?",
                              VunglePlayAdOptionKeyIncentivizedAlertCloseButtonText : @"Close",
                              VunglePlayAdOptionKeyIncentivizedAlertContinueButtonText : @"Keep Watching",
                              VunglePlayAdOptionKeyIncentivizedAlertTitleText : @"Careful!"};
    
    [sdk playAd:viewController
    withOptions:options
          error:&error];
}

- (void)unlockShowAdsAfterInterval
{
    _showAdsLocked = true;
    int64_t delayInSeconds = 30;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _showAdsLocked = false;
    });
}



#pragma mark VungleSDKDelegate

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    NSLog(@"%@", viewInfo);
    NSNumber *completed = [viewInfo objectForKey:@"completedView"];
    if (completed.boolValue == YES)
    {
        [self.delegate mgVungleDelegateAllocateReward];
    }
    
    [self unlockShowAdsAfterInterval];
}

- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable
{
    if (!isAdPlayable)
    {
        [self.delegate mgVungleDelegateAdVisibilityChanged:isAdPlayable];
    }
    else
    {
        if (_showAdsLocked)
        {
            [self.delegate mgVungleDelegateAdVisibilityChanged:NO];
        }
        else
        {
            [self.delegate mgVungleDelegateAdVisibilityChanged:isAdPlayable];
        }
    }
}

@end
