//
//  SoundUtils.m
//  game
//
//  Created by Marius Rott on 27/05/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import "SoundUtils.h"
#import "SettingsUtils.h"

@implementation SoundUtils

+ (void)playSoundNamed:(NSString *)soundName inScene:(SKScene *)scene
{
    if ([[SettingsUtils sharedInstance] soundIsOn])
    {
        [scene runAction:[SKAction playSoundFileNamed:soundName waitForCompletion:NO]];
    }
}

@end
