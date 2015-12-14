//
//  LayoutUtils.m
//  game
//
//  Created by Marius Rott on 05/05/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import "LayoutUtils.h"

@implementation LayoutUtils

+ (CGFloat)layoutValueForConfig:(LayoutConfig)layoutConfig
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        switch (layoutConfig)
        {
            case kLayoutMenuPadding:
                return 8;
            case kLayoutScreenMargin:
                return 20;
            case kLayoutCornerRadius:
                return 20;
            case kLayoutTitleFontSize:
                return 0.07;
            case kLayoutTextFontSize:
                return 0.03;
            case kLayoutScoreFontSize:
                return 0.05;
            case kLayoutSettingsPopupWidth:
                return 0.75;
            case kLayoutBannerHeight:
                return 50;
            case kLayoutShopCellHeight:
                return 50;
        }
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        switch (layoutConfig)
        {
            case kLayoutMenuPadding:
                return 10;
            case kLayoutScreenMargin:
                return 20;
            case kLayoutCornerRadius:
                return 30;
            case kLayoutTitleFontSize:
                return 0.08;
            case kLayoutTextFontSize:
                return 0.03;
            case kLayoutScoreFontSize:
                return 0.05;
            case kLayoutSettingsPopupWidth:
                return 0.5;
            case kLayoutBannerHeight:
                return 90;
            case kLayoutShopCellHeight:
                return 80;
        }
    }
    NSLog(@"undefined layout requested !!!!");
    return 0;
}

@end
