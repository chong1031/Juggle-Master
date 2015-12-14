//
//  RageIAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "IAPHelper.h"

@interface MGIAPHelper : IAPHelper

+ (MGIAPHelper *)sharedInstance;

- (void)buyProductIdentifier:(NSString*)productIdentifier withCompletionHandler:(void (^)(BOOL succceded))completionBlock;

+ (NSString *)priceForSKProduct:(SKProduct*)product;
+ (SKProduct *)getSKProductForBundleID:(NSString *)bundleID inArray:(NSArray*)products;

@end
