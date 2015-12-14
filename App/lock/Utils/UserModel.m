//
//  UserModel.m
//  game
//
//  Created by Marius Rott on 23/03/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import "UserModel.h"

#define KEY_LOCAL_SCORE     @"KEY_LOCAL_SCORE"

@implementation UserModel

+ (UserModel *)sharedInstance
{
    static UserModel *_singletonInstance = nil;
    
    if (_singletonInstance == nil) {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            _singletonInstance = [[UserModel alloc] init];
        });
    }
    
    return _singletonInstance;
}

- (NSNumber *)getHighscore
{
    NSNumber *score = [[NSUserDefaults standardUserDefaults] objectForKey:@"HIGHSCORE_GAME"];
    if (score == nil)
    {
        score = [NSNumber numberWithInt:0];
    }
    return score;
}

- (void)updateHighscore:(NSNumber *)highscore
{
    NSNumber *currentHighscore = [self getHighscore];
    if (highscore.intValue <= currentHighscore.intValue)
    {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:highscore forKey:@"HIGHSCORE_GAME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber *)getPoints
{
    NSNumber *score = [[NSUserDefaults standardUserDefaults] objectForKey:@"POINTS_GAME"];
    if (score == nil)
    {
        score = [NSNumber numberWithInt:0];
    }
    return score;
}

- (void)addPoints:(NSNumber *)points
{
    NSNumber *currentPoints = [self getPoints];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currentPoints.intValue + points.intValue] forKey:@"POINTS_GAME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)subtractPoints:(NSNumber *)points
{
    NSNumber *currentPoints = [self getPoints];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currentPoints.intValue - points.intValue] forKey:@"POINTS_GAME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
