//
//  Utils.m
//  game
//
//  Created by Marius Rott on 09/05/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (Utils *)sharedInstance
{
    static Utils *instance;
    if (instance == nil)
    {
        instance = [[Utils alloc] init];
    }
    return instance;
}

+ (UIColor*)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
    return color;
}

@end
