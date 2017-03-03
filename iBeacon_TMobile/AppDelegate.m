//
//  AppDelegate.m
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 23/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "AppDelegate.h"
#import "CouponViewController.h"
#import "HomeViewController.h"
#import "Beacon+CoreDataClass.h"
#import "Promo+CoreDataClass.h"
#import "Constants.h"
#import <AudioToolbox/AudioToolbox.h>
#import "WebViewController.h"

@interface AppDelegate (){
    NSMutableArray *_beacons;
    CLLocationManager *_locationManager;
    CLBeaconRegion *_region;
    CustomIOSAlertView *customAlertView;
    SystemSoundID mySound;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    sleep(1.0);
     [self registerDefaultsFromSettingsBundle];
    
    //load sound for new found promo
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"tap"
                                                withExtension: @"aif"];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)tapSound, &mySound);
    
    UIUserNotificationSettings *notifictionSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notifictionSettings];
    
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPromo) name:@"SHOW_PROMO" object:nil];
    _beacons = [[NSMutableArray alloc] init];
    
    //Reset the beacon found status to NO.
    [self setIsBeacon1Found:NO];
    [self setIsBeacon2Found:NO];
    [self setIsBeacon3Found:NO];
    [self setIsBeacon4Found:NO];
    [self setIsBeacon5Found:NO];
    
    // This location manager will be used to notify the user of region state transitions.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    if ([_locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    [self checkLocationAccessForMonitoring];
    //'[_locationManager startUpdatingLocation];
    [self startMonitoringForBeacons];
    
    [self handleAllLocalNotifcations];
    
    [self copyAllPromoImageToApplicationMemory];
    [self loadTop2PromosToCoreData];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *file = [directory stringByAppendingPathComponent:@"PromoImages"];
    NSLog(@"applicationWillEnterForeground %@",file);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AudioServicesDisposeSystemSoundID(mySound);
    
    [_locationManager stopRangingBeaconsInRegion:_region];
    [_locationManager stopMonitoringForRegion:_region];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self handleAllLocalNotifcations];
}

-(void)copyAllPromoImageToApplicationMemory{
    if (kIsCopied==nil) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *documentDBFolderPath = [documentsDirectory stringByAppendingPathComponent:@"PromoImages"];
        NSString *resourceDBFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PromoImages"];
        
        if (![fileManager fileExistsAtPath:documentDBFolderPath]) {
            //Create Directory!
            [fileManager createDirectoryAtPath:documentDBFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
        } else {
            NSLog(@"Directory exists! %@", documentDBFolderPath);
        }
        
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:resourceDBFolderPath error:&error];
        for (NSString *s in fileList) {
            NSString *newFilePath = [documentDBFolderPath stringByAppendingPathComponent:s];
            NSString *oldFilePath = [resourceDBFolderPath stringByAppendingPathComponent:s];
            if (![fileManager fileExistsAtPath:newFilePath]) {
                //File does not exist, copy it
                [fileManager copyItemAtPath:oldFilePath toPath:newFilePath error:&error];
            } else {
                NSLog(@"File exists: %@", newFilePath);
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCopied"];
        
    }else{
//        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *file = [directory stringByAppendingPathComponent:@"PromoImages/coupon1.png"];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
//           // NSLog(@"%@",[NSData dataWithContentsOfFile: file]);
//             NSLog(@"%@",file);
//        }
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.hcl.iBeacon_TMobile" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iBeacon_TMobile" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iBeacon_TMobile.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}




- (void)registerDefaultsFromSettingsBundle {
    // this function writes default settings as settings
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
            NSLog(@"writing as default %@ to the key %@",[prefSpecification objectForKey:@"DefaultValue"],key);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    
}

#pragma mark - Core Location Delegates

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSString *stateMessage = nil;
    
    if(state == CLRegionStateInside)
    {
        //TODO: Show message when user enters the region
        //        stateMessage = WELCOME_MESSAGE;
    }
    else if(state == CLRegionStateOutside)
    {
        //TODO: Show message when user leaves the region
        //        stateMessage = EXIT_MESSAGE;
    }
    else
    {
        return;
    }
    NSLog(@"didDetermineState : %@",region);

    if (stateMessage)
    {
        [self showPresencePopUp:stateMessage];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // CoreLocation will call this delegate method at 1 Hz with updated range information.
    
    /* TODO: Organize beacons based on proximity
     
     NSArray *unknownBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityUnknown]];
     if([unknownBeacons count])
     [_beacons setObject:unknownBeacons forKey:[NSNumber numberWithInt:CLProximityUnknown]];
     
     NSArray *immediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityImmediate]];
     if([immediateBeacons count])
     [_beacons setObject:immediateBeacons forKey:[NSNumber numberWithInt:CLProximityImmediate]];
     
     NSArray *nearBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityNear]];
     if([nearBeacons count])
     [_beacons setObject:nearBeacons forKey:[NSNumber numberWithInt:CLProximityNear]];
     
     NSArray *farBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityFar]];
     if([farBeacons count])
     [_beacons setObject:farBeacons forKey:[NSNumber numberWithInt:CLProximityFar]];
     
     */
    NSLog(@"didRangeBeacons : %lu",(unsigned long)beacons.count);
    if (kIsRegistered) {
        [_beacons removeAllObjects];
        [_beacons addObjectsFromArray:beacons];
        [self parseBeaconsForPromo];
    }
}


#pragma mark - Beacon handling methods

- (void)startMonitoringForBeacons
{
    if([PROMITYUUID_GIMBAL length] == 36){
        _region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:PROMITYUUID_GIMBAL] identifier:REGION_IDENTIFIER];
        _region.notifyOnEntry = YES;
        _region.notifyOnExit = YES;
        _region.notifyEntryStateOnDisplay = YES;
        
        
        [_locationManager startMonitoringForRegion:_region];
        [_locationManager startRangingBeaconsInRegion:_region];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Configure a valid Beacon UUID in Settings App" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}
- (void)checkLocationAccessForMonitoring {
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        if (authorizationStatus == kCLAuthorizationStatusDenied ||
            authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            NSLog(@"Location Access Missing");
            return;
        }
        [_locationManager requestAlwaysAuthorization];
//        [_locationManager requestWhenInUseAuthorization];
    }
}

- (void)parseBeaconsForPromo
{
    //Update the beacon visibility
    if ([_beacons count] == 0) {
        [self setIsBeacon1Found:NO];
        [self setIsBeacon2Found:NO];
        [self setIsBeacon3Found:NO];
        [self setIsBeacon4Found:NO];
        [self setIsBeacon5Found:NO];
    }
    
    for (CLBeacon *aBeacon in _beacons)
    {
        ////// dhaya /////////
        if (aBeacon.proximity != CLProximityUnknown) {
            NSMutableArray *beaconTemp1 =  [self checkBeaconBasedOnSettings:[NEAR_1 boolValue]  immdiate:[IMMEDIATE_1 boolValue] far:[FAR_1 boolValue]];
            for (NSNumber *number in beaconTemp1) {
                if (aBeacon.proximity == [number intValue])
                {
                    [self getPromoForBeacon:aBeacon];
                    break;
                }
            }
        }
        ////// dhaya ///////
        //        if (aBeacon.proximity == CLProximityImmediate || aBeacon.proximity == CLProximityNear)
        //        {
        //            [self getPromoForBeacon:aBeacon];
        //        }
    }
}

- (NSMutableArray *)checkBeaconBasedOnSettings:(NSInteger)near immdiate:(NSInteger)immdiate far:(NSInteger)far
{
    @autoreleasepool {
        
        NSMutableArray *temp = [[NSMutableArray alloc]init];
        if (near) {
            [temp addObject:[NSNumber numberWithInt:CLProximityNear]];
        }
        if (immdiate) {
            [temp addObject:[NSNumber numberWithInt:CLProximityImmediate]];
        }
        if (far) {
            [temp addObject:[NSNumber numberWithInt:CLProximityFar]];
        }
        return temp;
    }
}

- (void)getPromoForBeacon:(CLBeacon *)iBeacon
{
    //TODO: Make webservice request to get promo for a particular beacon.
    
    if (iBeacon.accuracy < MINIMUM_BEACON_PROXIMITY)
    {
        NSString* plistPath = @"";
        
        if ([iBeacon.minor intValue] == [MINOR_1 integerValue])
        {
            [self setIsBeacon1Found:YES];
            
            //Using beacon1 for Welcome/Exit message
            //Handled below after checking for if beacon recently handled
            plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Promo1"] ofType:@"plist"];
        }
        else if ([iBeacon.minor intValue] == [MINOR_2 integerValue])
        {
            [self setIsBeacon2Found:YES];
            plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Promo2"] ofType:@"plist"];
        }
        else if ([iBeacon.minor intValue] == [MINOR_3 integerValue])
        {
            [self setIsBeacon3Found:YES];
            plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Promo3"] ofType:@"plist"];
        }
        else if ([iBeacon.minor intValue] == [MINOR_4 integerValue])
        {
            [self setIsBeacon4Found:YES];
            plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Promo4"] ofType:@"plist"];
        }
        else if ([iBeacon.minor intValue] == [MINOR_5 integerValue])
        {
            [self setIsBeacon5Found:YES];
            plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Promo5"] ofType:@"plist"];
        }
        
        //Check if beacon communicated recently
        Beacon *availableBeacon = [self checkBeaconAvailabilityInCoreData:iBeacon];
        
        if (availableBeacon && availableBeacon.lastNotifiedTime)
        {
            //            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //            [dateFormatter setDateFormat:@"yyyy-MM-ddThh:mm:ss"];
            //            NSDate *date = [dateFormatter dateFromString:availableBeacon.lastNotifiedTime];
            
            NSDate *date = availableBeacon.lastNotifiedTime;
            
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
            if (interval < MINIMUM_BEACON_NOTIFICATION_TIME)
            {
                //Do not get promo for same beacon within specified timeinterval
                return;
            }
        }
        /*
        //Using beacon1 for Welcome/Exit message
        if ([iBeacon.minor intValue] == [MINOR_1 integerValue])
        {
            [self saveBeaconToCoreData:iBeacon];
            
            [self showPresencePopUp:WELCOME_MESSAGE];
            return;
        }
         */
        
        NSDictionary *contentDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        if (contentDict)
        {
            //Add the beacon to coredata Beacon table to check recent
            //TODO:Method call temporarily removed for showing promo(even if beacon was identified recently) after deleted from colection
            //            [self saveBeaconToCoreData:iBeacon];
            
            BOOL isPromoAvailable = [self checkPromoAvailablityInCD:[contentDict valueForKey:@"promoId"]];
            
            if (isPromoAvailable == NO)
            {
                if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
                {
                    [self addPromoToCollectionandCoreData:contentDict showPopUp:YES];
                }
                else
                {
                    [self scheduleForLocalNotification:contentDict];
                }
            }
        }
    }
    else
    {
        if ([iBeacon.minor intValue] == [MINOR_1 integerValue])
        {
            [self setIsBeacon1Found:NO];
        }
        else if ([iBeacon.minor intValue] == [MINOR_2 integerValue])
        {
            [self setIsBeacon2Found:NO];
        }
        else if ([iBeacon.minor intValue] == [MINOR_3 integerValue])
        {
            [self setIsBeacon3Found:NO];
        }
        else if ([iBeacon.minor intValue] == [MINOR_4 integerValue])
        {
            [self setIsBeacon4Found:NO];
        }
        else if ([iBeacon.minor intValue] == [MINOR_4 integerValue])
        {
            [self setIsBeacon5Found:NO];
        }
    }
}

- (BOOL)checkPromoAvailablityInCD:(NSString *)iPromoId
{
    BOOL isAvailable = NO;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Promo" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"promoId like[c] %@",iPromoId];
    
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([array count] > 0)
    {
        isAvailable = YES;
    }
    
    return isAvailable;
}


- (void)addPromoToCollectionandCoreData:(NSDictionary*)iPromo showPopUp:(BOOL)showPopUp
{
    NSManagedObjectContext *moc = [kAppDelegate managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Promo" inManagedObjectContext:moc];
    
    Promo *promo = [[Promo alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
    
    [promo setValue:[iPromo valueForKey:@"title"] forKey:@"promoTitle"];
    [promo setValue:[iPromo valueForKey:@"promoId"] forKey:@"promoId"];
    //[promo setValue:[iPromo valueForKey:@"description"] forKey:@"promoDescription"];
    //[promo setValue:[NSNumber numberWithInteger:[[iPromo valueForKey:@"rating"] integerValue]] forKey:@"promoRating"];
    //[promo setValue:[NSNumber numberWithInteger:[[iPromo valueForKey:@"totalRatings"] integerValue]] forKey:@"promoTotalRatings"];
    //[promo setValue:[NSNumber numberWithInteger:[[iPromo valueForKey:@"isFemale"] integerValue]] forKey:@"isFemale"];
    
    /*
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    ////    [dateFormatter setDateFormat:@"yyyy-MM-ddThh:mm:ss"];
    //    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    //    NSDate *startDate = [dateFormatter dateFromString:[iPromo valueForKey:@"startDate"]];
    //    NSDate *endDate = [dateFormatter dateFromString:[iPromo valueForKey:@"endDate"]];
    //
    */
    
    //[promo setValue:[iPromo valueForKey:@"oldPrice"] forKey:@"promoOldPrice"];
    //[promo setValue:[iPromo valueForKey:@"newPrice"] forKey:@"promoNewPrice"];
    
    //temporary bundle image reading
    
//    NSString *thumbImagePath = [[NSBundle mainBundle] pathForResource:[iPromo valueForKey:@"imageThumb"] ofType:@"png"];
//
//    
//    UIImage *thumbImage = [UIImage imageNamed:[iPromo valueForKey:@"imageThumb"]];
//    UIImage *largeImage = [UIImage imageNamed:[iPromo valueForKey:@"imageLarge"]];
    
//    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *file = [directory stringByAppendingPathComponent:@"PromoImages"];
    
    [promo setValue:[iPromo valueForKey:@"imageThumb"] forKey:@"promoImageThumb"];
    [promo setValue:[iPromo valueForKey:@"imageLarge"] forKey:@"promoImageLarge"];
    
//    [promo setValue:[file stringByAppendingPathComponent:[iPromo valueForKey:@"imageThumb"]] forKey:@"promoImageThumb"];
//    [promo setValue:[file stringByAppendingPathComponent:[iPromo valueForKey:@"imageLarge"]] forKey:@"promoImageLarge"];
//    
    
    //[promo setValue:UIImagePNGRepresentation(largeImage) forKey:@"promoImageLarge"];
    
    //[promo setValue:[iPromo valueForKey:@"offerValue"] forKey:@"promoOffer"];
    //[promo setValue:[iPromo valueForKey:@"validity"] forKey:@"promoEndDate"];
    //[promo setValue:[iPromo valueForKey:@"code"] forKey:@"promoCode"];
    
    [promo setValue:[NSNumber numberWithBool:NO] forKey:@"isRead"];
    [promo setValue:[NSDate date] forKey:@"promoSyncDate"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![moc save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
   // if (showPopUp) [self showPopUpForPromo:promo];
    if (showPopUp){
//        if([[promo promoId] isEqualToString:@"00004"]){
//            [self showPopUpForPromo:promo];
//        }else{
            [self loadWebView:promo];
//        }
    }
    //[self postReloadCoupons];
    [self saveContext];
}

-(void)loadWebView:(Promo*)promo{
    
    [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    
    WebViewController *webViewController = (WebViewController*)[mainStoryboard
                                                                instantiateViewControllerWithIdentifier: @"WebViewClass"];
    [webViewController setPromoObj:promo];
    
    [self.window.rootViewController presentViewController:webViewController animated:YES completion:nil];
    AudioServicesPlaySystemSound(mySound);
}

- (void)showPopUpForPromo:(Promo *)iPromo
{
    if(customAlertView!=nil){
        [customAlertView close];
        customAlertView = nil;
    }
    // Here we need to pass a full frame
    customAlertView = [[CustomIOSAlertView alloc] init];
    
    // Add some custom content to the alert view
    [customAlertView setContainerView:[self createPromoView:iPromo]];
    
    // Modify the parameters
    [customAlertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
    //[alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [customAlertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
  
            UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
            UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
            
            if([lastViewController isMemberOfClass:[HomeViewController class]]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_PROMO_LIST" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_COUPONS_NOTIF
                                                                    object:self
                                                                  userInfo:nil];
            }
        
        [alertView close];
    }];
    
    [customAlertView setUseMotionEffects:true];
    
    // And launch the dialog
    [customAlertView show];
    AudioServicesPlaySystemSound(mySound);
}

- (UIView *)createPromoView:(Promo *)iPromo
{
    UIView *promoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 460, 607)];
    
    UIImageView *newImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 32, 32)];
    [newImg setImage:[UIImage imageNamed:@"new"]];
    [promoView addSubview:newImg];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 440, 30)];
    lbl.text = @"New Agenda";
    lbl.font = [UIFont boldSystemFontOfSize:17.0f];
    lbl.textAlignment = NSTextAlignmentCenter;
    [promoView addSubview:lbl];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 40, 440, 547)];
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *imgPath = [NSString stringWithFormat:@"%@/%@",[directory stringByAppendingPathComponent:@"PromoImages"],iPromo.promoImageLarge];
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:imgPath];
    [imageView setImage:[UIImage imageWithData:data]];
    [promoView addSubview:imageView];
    
    return promoView;
}


- (void)postReloadCoupons
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_COUPONS_NOTIF
                                                        object:self
                                                      userInfo:nil];
}

#pragma mark - CoreData transaction methods

- (Beacon *)checkBeaconAvailabilityInCoreData:(CLBeacon *)iBeacon
{
    NSManagedObjectContext *moc = [kAppDelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Beacon" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    
    NSNumber *major = iBeacon.major;
    NSNumber *minor = iBeacon.minor;
    NSString *UUID = [iBeacon.proximityUUID UUIDString];
    
    
    NSPredicate *predicate = nil;
    
    if(major && minor)
    {
        predicate = [NSPredicate predicateWithFormat:
                     @"(major == %@) AND (minor == %@) AND (proximityUUID == %@)", major, minor, UUID];
    }
    else if(major)
    {
        predicate = [NSPredicate predicateWithFormat:
                     @"(major == %@) AND (proximityUUID == %@)", major, UUID];
    }
    else if(minor)
    {
        predicate = [NSPredicate predicateWithFormat:
                     @"(minor == %@) AND (proximityUUID == %@)", minor, UUID];
    }
    
    if (predicate)[request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    if (array == nil)return nil;
    
    if ([array count] > 0)
    {
        return [array objectAtIndex:0];
    }
    else
    {
        return nil;
    }
}

- (void)saveBeaconToCoreData:(CLBeacon *)iBeacon
{
    NSManagedObjectContext *moc = [kAppDelegate managedObjectContext];
    // Create a new managed object
    
    Beacon *aBeacon = [self checkBeaconAvailabilityInCoreData:iBeacon];
    
    if (!aBeacon)
    {
        aBeacon = [NSEntityDescription insertNewObjectForEntityForName:@"Beacon" inManagedObjectContext:moc];
        [aBeacon setValue:[iBeacon.proximityUUID UUIDString] forKey:@"proximityUUID"];
        [aBeacon setValue:iBeacon.major forKey:@"major"];
        [aBeacon setValue:iBeacon.minor forKey:@"minor"];
    }
    
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [aBeacon setValue:[NSDate date] forKey:@"lastNotifiedTime"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![moc save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)deleteAllBeaconFromCD
{
    NSManagedObjectContext *moc = [kAppDelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Beacon" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    for (Beacon *beacon in array)
    {
        [moc deleteObject:beacon];
    }
    
    // Save the object to persistent store
    if (![moc save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)deleteAllPromosFromCD
{
    NSManagedObjectContext *moc = [kAppDelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Promo" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    for (Beacon *beacon in array)
    {
        [moc deleteObject:beacon];
    }
    
    // Save the object to persistent store
    if (![moc save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)loadTop2PromosToCoreData
{
    NSString* plistPath = @"";
    
    // Load promo5, promo6 by default; for not showing an empty screen
    for (int i = 1; i < 6; i++)
    {
        plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Promo%d",i] ofType:@"plist"];
        
        NSDictionary *contentDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        if (contentDict)
        {
            BOOL isPromoAvailable = [self checkPromoAvailablityInCD:[contentDict valueForKey:@"promoId"]];
            
            if (isPromoAvailable == NO)
            {
                [self addPromoToCollectionandCoreData:contentDict showPopUp:NO];
            }
        }
    }
}


- (void)showPresencePopUp:(NSString *)iMessage
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        //Show alert if app is in foreground and active
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iMessage message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        AudioServicesPlaySystemSound(mySound);
    }
    else
    {
        NSDictionary *welcomeNotif = @{@"promoId":iMessage,@"title":iMessage};
        [self scheduleForLocalNotification:welcomeNotif];
    }
}

-(void)scheduleForLocalNotification:(NSDictionary *)notif
{
    BOOL isNotificationAlreadyScheduled = NO;
    
    NSArray *storedNotifs = [[NSUserDefaults standardUserDefaults] objectForKey:@"scheduledNotifs"];
    
    for (NSDictionary* scheduledNotif in storedNotifs)
    {
        if ([[notif valueForKey:@"promoId"] isEqualToString:[scheduledNotif valueForKey:@"promoId"]])
        {
            isNotificationAlreadyScheduled = YES;
            break;
        }
    }
    
    if (isNotificationAlreadyScheduled == NO)
    {
        // A user can transition in or out of a region while the application is not running.
        // When this happens CoreLocation will launch the application momentarily, call this delegate method
        // and we will let the user know via a local notification.
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.userInfo = notif;
        notification.soundName = @"tap.aif";
        notification.alertBody = [notif valueForKey:@"title"];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
//
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
        NSMutableArray *newNotifList = [NSMutableArray arrayWithArray:storedNotifs];
        [newNotifList addObject:notif];
        
        [[NSUserDefaults standardUserDefaults] setObject:newNotifList forKey:@"scheduledNotifs"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)deleteAllScheduledNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSArray *emptyArray = [[NSArray alloc] initWithObjects:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:emptyArray forKey:@"scheduledNotifs"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)handleAllLocalNotifcations
{
    NSArray *storedNotifs = [[NSUserDefaults standardUserDefaults] objectForKey:@"scheduledNotifs"];
    
    for (NSDictionary *notification in storedNotifs)
    {
//        if ([[notification valueForKey:@"promoId"] isEqualToString:WELCOME_MESSAGE])
//        {
//            // If the application is in the foreground, we will notify the user of the region's state via an alert.
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[notification valueForKey:@"promoId"] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            
//           // AudioServicesPlaySystemSound(mySound);
//        }
//        else
//        {
            BOOL isPromoAvailable = [self checkPromoAvailablityInCD:[notification valueForKey:@"promoId"]];
            
            if (isPromoAvailable == NO)
            {
                [self addPromoToCollectionandCoreData:notification showPopUp:YES];
            }
//        }
    }
    
    [self deleteAllScheduledNotification];
}

@end
