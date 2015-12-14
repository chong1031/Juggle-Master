//
//  Ball.h
//  lock
//
//  Created by Rott Marius Gabriel on 04/11/15.
//  Copyright © 2015 mrott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ball : SKSpriteNode

@property (nonatomic, assign) CGFloat dx;
@property (nonatomic, assign) CGFloat dy;
@property (nonatomic, assign) CGFloat accelerationY;

+ (Ball*)ballWithImageNamed:(NSString*)imageName;

@end
