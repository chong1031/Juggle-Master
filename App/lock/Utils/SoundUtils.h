//
//  SoundUtils.h
//  game
//
//  Created by Marius Rott on 27/05/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface SoundUtils : NSObject

+ (void)playSoundNamed:(NSString*)soundName inScene:(SKScene*)scene;

@end
