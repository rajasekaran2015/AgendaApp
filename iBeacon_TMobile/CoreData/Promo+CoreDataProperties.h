//
//  Promo+CoreDataProperties.h
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 27/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "Promo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Promo (CoreDataProperties)

+ (NSFetchRequest<Promo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *isRead;
@property (nullable, nonatomic, copy) NSString *promoId;
@property (nullable, nonatomic, copy) NSString *promoImageLarge;
@property (nullable, nonatomic, copy) NSString *promoImageThumb;
@property (nullable, nonatomic, copy) NSDate *promoSyncDate;
@property (nullable, nonatomic, copy) NSString *promoTitle;

@end

NS_ASSUME_NONNULL_END
