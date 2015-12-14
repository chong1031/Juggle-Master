//
//  MGConfiguration.h
//  MGAds
//
//  Created by Marius Rott on 11/23/12.
//  Copyright (c) 2012 Marius Rott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "configuration.h"

#define     MG_REFETCH_AFTER            30

#define     MG_APP_AD_MIN_DISPLAY       1
#define     MG_APP_AD_SECONDS_BETWEEN   90


typedef enum
{
    MgAdsProviderStartApp = 1,
    MgAdsProviderChartboost,
    MgAdsProviderAppLovin
} MgAdsTypeProvider;

#define     MG_ADS_PROVIDER_ORDER_1     MgAdsProviderAppLovin
#define     MG_ADS_PROVIDER_ORDER_2     MgAdsProviderStartApp
#define     MG_ADS_PROVIDER_ORDER_3     MgAdsProviderChartboost
#define     MG_ADS_NUM_PROVIDERS        3

