//
//  AppDelegate.h
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 23/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomIOSAlertView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property(nonatomic) BOOL isBeacon1Found;
@property(nonatomic) BOOL isBeacon2Found;
@property(nonatomic) BOOL isBeacon3Found;
@property(nonatomic) BOOL isBeacon4Found;
@property(nonatomic) BOOL isBeacon5Found;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)deleteAllScheduledNotification;
- (void)handleAllLocalNotifcations;
- (void)deleteAllBeaconFromCD;
- (void)deleteAllPromosFromCD;
@end

