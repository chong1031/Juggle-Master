//
//  configuration.h
//  game
//
//  Created by Marius Rott on 23/03/15.
//  Copyright (c) 2015 mrott. All rights reserved.
//

//  SUPPORT
#define     SETTINGS_SUPPORT_EMAIL      @"contact@mgapps.net"

#define     APPLICATION_ID              1056612701
#define     GAME_APP_STORE_PAGE         [NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%d?mt=8", APPLICATION_ID]
#define     DEVELOPER_APP_STORE_PAGE    @"https://itunes.apple.com/us/artist/rott-marius-gabriel/id448770802"

#define     STORE_BUNDLE_IN_APP_DISABLE_ADS      @"com.mrott.juggle.disableads"

//  flurry
#define     FLURRY_APP_ID               @"R5TV74HRMBRRFNTWP6CK"

//  FULLSCREEN ADS
#define     MG_ADS_CHARTBOOST_APP_ID    @"5617adfc5b145349706cc4fc"
#define     MG_ADS_CHARTBOOST_APP_SIG   @"29a92bea221bb3b77bf802fa30213bbced7e990d"

#define     MG_ADS_STARTAPP_APP_ID      @"209268070"
#define     MG_ADS_STARTAPP_DEV_ID      @"107167423"

//  Vungle
#define     VUNGLE_APP_ID               @"563b50b8206a9c1520000036"
#define     VUNGLE_REPORTING_ID         @"563b50b8206a9c1520000036"

#define     VUNGLE_BONUS_POINTS         500

//  leaderboard
#define     LEADERBOARD_ID              @"com.mrott.juggle.leaderboard"

//  Share
#define     SHARE_URL                   GAME_APP_STORE_PAGE
#define     SHARE_TEXT                  @"Check this awesome game. Can you beat my highscore?"

#define SOUND_BUTTON_TAP                @"Button A2.wav"
#define SOUND_CORRECT_COLLIDE           @"Button B2.wav"
#define SOUND_GAME_COMPLETED            @"Game Completed.wav"
#define SOUND_GAME_FAILED               @"Game Failed.wav"

//  Local Notifications Setup
#define     LOCAL_NOTIFICATION_1            NSLocalizedString(@"Can you beat your record? Improve your score today!", nil)
#define     LOCAL_NOTIFICATION_2            NSLocalizedString(@"Play Double Juggle again. You can improve your score now!", nil)
#define     LOCAL_NOTIFICATION_3            NSLocalizedString(@"Have a great time with a Double Juggle game right now!", nil)
#define     LOCAL_NOTIFICATION_4            NSLocalizedString(@"Improve your speed with a Double Juggle game today!", nil)
