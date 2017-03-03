//
//  Beacon+CoreDataProperties.m
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 27/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "Beacon+CoreDataProperties.h"

@implementation Beacon (CoreDataProperties)

+ (NSFetchRequest<Beacon *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Beacon"];
}

@dynamic lastNotifiedTime;
@dynamic major;
@dynamic minor;
@dynamic proximityUUID;

@end
