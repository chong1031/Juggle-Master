//
//  MWSettingsUtils.h
//  sevenminutes
//
//  Created by Marius Rott on 06/05/14.
//  Copyright (c) 2014 Marius Rott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsUtils : NSObject

+ (SettingsUtils *)sharedInstance;

- (void)initialSetup;

- (BOOL)soundIsOn;
- (void)setSoundOn:(BOOL)soundOn;

@end
