//
//  AppDelegate.m
//  lock
//
//  Created by Marius Rott on 24/09/15.
//  Copyright © 2015 mrott. All rights reserved.
//

#import "AppDelegate.h"

#import "MGAdsManager.h"
#import "MGVungle.h"
#import "SettingsUtils.h"
#import <Flurry-iOS-SDK/Flurry.h>
#import "MKLocalNotificationsScheduler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[MGAdsManager sharedInstance] startAdsManager];
    [[MGVungle sharedInstance] startMGVungle];
    [[SettingsUtils sharedInstance] initialSetup];
    [Flurry startSession:FLURRY_APP_ID];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self localNotificationsSetup];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[MGAdsManager sharedInstance] appDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)localNotificationsSetup
{
    //  remove all notifications & clear badge count
    [[MKLocalNotificationsScheduler sharedInstance] clearBadgeCount];
    [[MKLocalNotificationsScheduler sharedInstance] removeAllNotifications];
    
    NSArray *messages = [NSArray arrayWithObjects:LOCAL_NOTIFICATION_1, LOCAL_NOTIFICATION_2, LOCAL_NOTIFICATION_3, LOCAL_NOTIFICATION_4, nil];
    
    for (int i = 0; i < messages.count; i++)
    {
        [[MKLocalNotificationsScheduler sharedInstance] scheduleNotificationOn:[NSDate dateWithTimeIntervalSinceNow:60*60*24*4*(i+1)]
                                                                  repeatWeekly:NO
                                                                          text:[messages objectAtIndex:i]
                                                                        action:@"View"
                                                                         sound:nil
                                                                   launchImage:nil
                                                                       andInfo:nil];
    }
}

@end
