//
//  MGVungle.h
//  lock
//
//  Created by Rott Marius Gabriel on 05/11/15.
//  Copyright © 2015 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MGVungleDelegate <NSObject>

- (void)mgVungleDelegateAdVisibilityChanged:(BOOL)isAdPlayable;
- (void)mgVungleDelegateAllocateReward;

@end

@interface MGVungle : NSObject

+ (MGVungle*)sharedInstance;

- (BOOL)isAdPlayable;
- (void)startMGVungle;
- (void)setDelegate:(id<MGVungleDelegate>)delegate;

- (void)openIncentivizedAdInViewController:(UIViewController*)viewController;

@end
