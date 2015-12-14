//
//  Utils.h
//  game
//
//  Created by Marius Rott on 09/05/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameViewController.h"

@interface Utils : NSObject

@property (nonatomic, assign) id<GameViewControllerDelegate> gameViewControllerDelegate;
@property (nonatomic, strong) UIViewController *viewController;

+ (Utils *)sharedInstance;

+ (UIColor*)randomColor;

@end
