//
//  MKLocalNotificationsScheduler.h
//  LocalNotifs
//
//  Created by Mugunth Kumar on 9-Aug-10.
//  Copyright 2010 Steinlogic. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://mugunthkumar.com
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MKLocalNotificationsScheduler : NSObject {

	int _badgeCount;
}

@property (nonatomic, assign) BOOL notificationsOn;

+ (MKLocalNotificationsScheduler*) sharedInstance;

- (void) scheduleNotificationOn:(NSDate*) fireDate
                   repeatWeekly:(BOOL)repeat
						   text:(NSString*) alertText
						 action:(NSString*) alertAction
						  sound:(NSString*) soundfileName
					launchImage:(NSString*) launchImage 
						andInfo:(NSDictionary*) userInfo;

- (void) handleReceivedNotification:(UILocalNotification*) thisNotification;

- (void) decreaseBadgeCountBy:(int) count;
- (void) clearBadgeCount;

- (void) removeAllNotifications;

@property int badgeCount;
@end
