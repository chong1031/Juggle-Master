//
//  LayoutUtils.h
//  game
//
//  Created by Marius Rott on 05/05/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    kLayoutMenuPadding,
    kLayoutScreenMargin,
    kLayoutCornerRadius,
    kLayoutSettingsPopupWidth,
    kLayoutBannerHeight,
    
    kLayoutShopCellHeight,
    
    kLayoutTitleFontSize,
    kLayoutTextFontSize,
    kLayoutScoreFontSize,
} LayoutConfig;

@interface LayoutUtils : NSObject

+ (CGFloat)layoutValueForConfig:(LayoutConfig)layoutConfig;

@end
