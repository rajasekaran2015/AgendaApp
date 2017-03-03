//
//  Beacon+CoreDataProperties.h
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 27/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "Beacon+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Beacon (CoreDataProperties)

+ (NSFetchRequest<Beacon *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *lastNotifiedTime;
@property (nullable, nonatomic, copy) NSNumber *major;
@property (nullable, nonatomic, copy) NSNumber *minor;
@property (nullable, nonatomic, copy) NSString *proximityUUID;

@end

NS_ASSUME_NONNULL_END
