//
//  MWSettingsUtils.h
//  sevenminutes
//
//  Created by Marius Rott on 06/05/14.
//  Copyright (c) 2014 Marius Rott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BallsUtils : NSObject

+ (BallsUtils *)sharedInstance;

- (NSUInteger)numberOfBalls;
- (NSString*)imageNameForBallAtIndex:(int)index;
- (int)priceForBallAtIndex:(int)index;
- (BOOL)isBallPurchasedWithIndex:(int)index;
- (int)getCurrentBallIndex;

- (void)setCurrentBallWithIndex:(int)index;
- (void)purchaseBallWithIndex:(int)index;

@end
