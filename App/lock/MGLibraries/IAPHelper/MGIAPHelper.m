//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "MGIAPHelper.h"
#import "configuration.h"

@implementation MGIAPHelper

+ (MGIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static MGIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      STORE_BUNDLE_IN_APP_DISABLE_ADS,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (void)buyProductIdentifier:(NSString *)productIdentifier withCompletionHandler:(void (^)(BOOL))completionBlock
{
    [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (!success) {
            completionBlock(success);
        }
        else
        {
            SKProduct *product = [self getSKProductForBundleID:productIdentifier inArray:products];
            [self buyProduct:product];
        }
    }];
}

- (SKProduct *)getSKProductForBundleID:(NSString *)bundleID inArray:(NSArray*)array
{
    if (array != nil && [array count] > 0)
    {
        for (SKProduct *tmp in array)
        {
            if ([tmp.productIdentifier compare:bundleID] == NSOrderedSame)
            {
                return tmp;
            }
        }
    }
    return nil;
}

+ (NSString *)priceForSKProduct:(SKProduct*)product
{
    if (!product)
    {
        return nil;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *price = [numberFormatter stringFromNumber:product.price];
    return price;
}

+ (SKProduct *)getSKProductForBundleID:(NSString *)bundleID inArray:(NSArray*)products
{
    if (products != nil && [products count] > 0)
    {
        for (SKProduct *tmp in products)
        {
            if ([tmp.productIdentifier compare:bundleID] == NSOrderedSame)
            {
                return tmp;
            }
        }
    }
    return nil;
}

@end
