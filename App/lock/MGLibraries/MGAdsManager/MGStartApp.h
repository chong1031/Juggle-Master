//
//  MGAppLovin.h
//  flows
//
//  Created by Marius Rott on 16/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAdsManager.h"
#import <StartApp/StartApp.h>

@interface MGStartApp : NSObject <MGAdsProvider, STADelegateProtocol>
{
    bool _isAvailable;
}

@property (strong, atomic)    STAStartAppAd* cachedAd;

@end
