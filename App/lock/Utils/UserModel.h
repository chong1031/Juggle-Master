//
//  UserModel.h
//  game
//
//  Created by Marius Rott on 23/03/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "configuration.h"

@interface UserModel : NSObject

+ (UserModel*)sharedInstance;

- (NSNumber*)getHighscore;
- (void)updateHighscore:(NSNumber*)highscore;

- (NSNumber*)getPoints;
- (void)addPoints:(NSNumber*)points;
- (void)subtractPoints:(NSNumber*)points;

@end
