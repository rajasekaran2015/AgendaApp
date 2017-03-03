//
//  Constants.h
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 23/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#ifndef Constants_h
#define Constants_h

#define MINIMUM_BEACON_PROXIMITY 3.0//1.5
#define MINIMUM_BEACON_NOTIFICATION_TIME 3600

#define REGION_IDENTIFIER @"com.hcl.iBeacon-TMobile"
//#define REGION_IDENTIFIER @"com.HCL.iBeacon_Template"

#define PROMITYUUID_GIMBAL [[NSUserDefaults standardUserDefaults] valueForKey:@"uuid"]
#define MINOR_1 [[NSUserDefaults standardUserDefaults] valueForKey:@"minor1"]
#define MINOR_2 [[NSUserDefaults standardUserDefaults] valueForKey:@"minor2"]
#define MINOR_3 [[NSUserDefaults standardUserDefaults] valueForKey:@"minor3"]
#define MINOR_4 [[NSUserDefaults standardUserDefaults] valueForKey:@"minor4"]
#define MINOR_5 [[NSUserDefaults standardUserDefaults] valueForKey:@"minor5"]

#define MAJOR_1 [[NSUserDefaults standardUserDefaults] valueForKey:@"major1"]
#define MAJOR_2 [[NSUserDefaults standardUserDefaults] valueForKey:@"major2"]
#define MAJOR_3 [[NSUserDefaults standardUserDefaults] valueForKey:@"major3"]
#define MAJOR_4 [[NSUserDefaults standardUserDefaults] valueForKey:@"major4"]
#define MAJOR_5 [[NSUserDefaults standardUserDefaults] valueForKey:@"major5"]

#define NEAR_1 [[NSUserDefaults standardUserDefaults] valueForKey:@"Near1"]
#define IMMEDIATE_1 [[NSUserDefaults standardUserDefaults] valueForKey:@"Immediate1"]
#define FAR_1 [[NSUserDefaults standardUserDefaults] valueForKey:@"Far1"]


#define IGNORE_BTN_TITLE @"Ignore"
#define OPEN_BTN_TITLE @"Open"

#define EXIT_MESSAGE @"See you again at iPromos store"

#define BEACONS @"Beacons"

#define RELOAD_COUPONS_NOTIF @"ReloadCoupons"

#define kAppDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define kIsUserFemale [[NSUserDefaults standardUserDefaults] valueForKey:@"isFemale"]
#define kIsRegistered [[NSUserDefaults standardUserDefaults] valueForKey:@"isRegistered"]
#define kUserName getEmptyStrOnNull([[NSUserDefaults standardUserDefaults] valueForKey:@"name"])
#define kUserAge getEmptyStrOnNull([[NSUserDefaults standardUserDefaults] valueForKey:@"age"])

#define kIsCopied [[NSUserDefaults standardUserDefaults] valueForKey:@"isCopied"]

#define WELCOME_MESSAGE [NSString stringWithFormat:@"Welcome %@ to the HCL. \nHope you enjoy the our visit!!!",kUserName]

#endif /* Constants_h */
