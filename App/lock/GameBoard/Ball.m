//
//  Ball.m
//  lock
//
//  Created by Rott Marius Gabriel on 04/11/15.
//  Copyright © 2015 mrott. All rights reserved.
//

#import "Ball.h"

@implementation Ball

+ (Ball *)ballWithImageNamed:(NSString *)imageName
{
    Ball *ball = [super spriteNodeWithImageNamed:imageName];
    ball.accelerationY = 0;
    return ball;
}

@end
