//
//  MWSettingsUtils.m
//  sevenminutes
//
//  Created by Marius Rott on 06/05/14.
//  Copyright (c) 2014 Marius Rott. All rights reserved.
//

#import "BallsUtils.h"
#import "configuration.h"

#define KEY_INDEX                   @"index"
#define KEY_PRICE                   @"price"
#define KEY_IMAGE                   @"image"
#define KEY_PURCHASE_BALL           @"KEY_PURCHASE_BALL"
#define KEY_CURRENT_BALL            @"KEY_CURRENT_BALL"


@interface BallsUtils ()
{
    NSArray *balls;
}

@end

@implementation BallsUtils

+ (BallsUtils *)sharedInstance
{
    static BallsUtils *instance;
    if (instance == nil)
    {
        instance = [[BallsUtils alloc] init];
        [instance loadBalls];
        [instance initialSetup];
    }
    return instance;
}

- (void)loadBalls
{
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"balls" ofType:@"json"];
    NSError *error;
    NSStringEncoding encoding = 0;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath
                                                   usedEncoding:&encoding
                                                          error:&error];
    
    if (error)
    {
        NSLog(@"Error reading file: %@", error.localizedDescription);
    }
    else
    {
        NSError *error2 = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[fileContents dataUsingEncoding:encoding]
                                                             options:kNilOptions
                                                               error:&error2];
        balls = [dict objectForKey:@"array"];
    }
}

- (void)initialSetup
{
    if ([self getCurrentBallIndex] == -1)
    {
        [self purchaseBallWithIndex:0];
        [self setCurrentBallWithIndex:0];
    }
}

- (NSUInteger)numberOfBalls
{
    return balls.count;
}

- (NSString *)imageNameForBallAtIndex:(int)index
{
    NSDictionary *ball = [balls objectAtIndex:index];
    NSString *imageName = [ball objectForKey:KEY_IMAGE];
    return imageName;
}

- (int)priceForBallAtIndex:(int)index
{
    NSDictionary *ball = [balls objectAtIndex:index];
    NSNumber *price = [ball objectForKey:KEY_PRICE];
    return price.intValue;
}

- (BOOL)isBallPurchasedWithIndex:(int)index
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%d", KEY_PURCHASE_BALL, index];
    NSNumber *ballIsPurchased = [userDefaults objectForKey:key];
    return ballIsPurchased != nil;
}

- (int)getCurrentBallIndex
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *currentBall = [userDefaults objectForKey:KEY_CURRENT_BALL];
    if (currentBall)
    {
        return currentBall.intValue;
    }
    return -1;
}

- (void)setCurrentBallWithIndex:(int)index
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInt:index]
                     forKey:KEY_CURRENT_BALL];
    [userDefaults synchronize];
}

- (void)purchaseBallWithIndex:(int)index
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%d", KEY_PURCHASE_BALL, index];
    [userDefaults setBool:YES forKey:key];
    [userDefaults synchronize];
}

@end