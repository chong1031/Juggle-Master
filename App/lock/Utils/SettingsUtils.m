//
//  MWSettingsUtils.m
//  sevenminutes
//
//  Created by Marius Rott on 06/05/14.
//  Copyright (c) 2014 Marius Rott. All rights reserved.
//

#import "SettingsUtils.h"
#import "configuration.h"

#define KEY_SETTINGS_SOUND_ON       @"KEY_SETTINGS_SOUND_ON"
#define KEY_SETTINGS_MUSIC_ON       @"KEY_SETTINGS_MUSIC_ON"
#define KEY_SETTINGS_NOTIFICATIONS  @"KEY_SETTINGS_NOTIFICATION"
#define KEY_SETTINGS_SEEN_HELP      @"KEY_SETTINGS_SEEN_HELP"


@implementation SettingsUtils

+ (SettingsUtils *)sharedInstance
{
    static SettingsUtils *instance;
    if (instance == nil)
    {
        instance = [[SettingsUtils alloc] init];
    }
    return instance;
}

- (void)initialSetup
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:KEY_SETTINGS_SOUND_ON] == nil)
    {
        [userDefaults setBool:YES forKey:KEY_SETTINGS_SOUND_ON];
    }
    if ([userDefaults objectForKey:KEY_SETTINGS_MUSIC_ON] == nil)
    {
        [userDefaults setBool:NO forKey:KEY_SETTINGS_MUSIC_ON];
    }
    if ([userDefaults objectForKey:KEY_SETTINGS_NOTIFICATIONS] == nil)
    {
        [userDefaults setBool:YES forKey:KEY_SETTINGS_NOTIFICATIONS];
    }
    
    [userDefaults synchronize];
}

- (BOOL)soundIsOn
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *soundIsOn = [userDefaults objectForKey:KEY_SETTINGS_SOUND_ON];
    if (soundIsOn && soundIsOn.boolValue == YES)
    {
        return YES;
    }
    return NO;
}

- (void)setSoundOn:(BOOL)soundOn
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:soundOn forKey:KEY_SETTINGS_SOUND_ON];
    [userDefaults synchronize];
}

- (BOOL)musicIsOn
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *musicIsOn = [userDefaults objectForKey:KEY_SETTINGS_MUSIC_ON];
    if (musicIsOn && musicIsOn.boolValue == YES)
    {
        return YES;
    }
    return NO;
}

- (void)setMusicOn:(BOOL)musicOn
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:musicOn forKey:KEY_SETTINGS_MUSIC_ON];
    [userDefaults synchronize];
}

- (BOOL)notificationsIsOn
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *notificationsIsOn = [userDefaults objectForKey:KEY_SETTINGS_NOTIFICATIONS];
    if (notificationsIsOn && notificationsIsOn.boolValue == YES)
    {
        return YES;
    }
    return NO;
}

- (void)setNotificationsOn:(BOOL)notificationsOn
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:notificationsOn forKey:KEY_SETTINGS_NOTIFICATIONS];
    [userDefaults synchronize];
}

- (BOOL)hasSeenHelp
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *hasSeen = [userDefaults objectForKey:KEY_SETTINGS_SEEN_HELP];
    if (hasSeen && hasSeen.boolValue == YES)
    {
        return YES;
    }
    return NO;
}

- (void)setHasSeenHelp:(BOOL)hasSeen
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:hasSeen forKey:KEY_SETTINGS_SEEN_HELP];
    [userDefaults synchronize];
}

- (void)setHasPurchasedDifficultyLevel:(int)difficulty
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"KEY_SETTINGS_DIFFICULTY_%d", difficulty];
    [userDefaults setBool:YES forKey:key];
    [userDefaults synchronize];
}

- (BOOL)hasPurchasedDifficultyLevel:(int)difficulty
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"KEY_SETTINGS_DIFFICULTY_%d", difficulty];
    NSNumber *hasSeen = [userDefaults objectForKey:key];
    if (hasSeen && hasSeen.boolValue == YES)
    {
        return YES;
    }
    return NO;
}

@end