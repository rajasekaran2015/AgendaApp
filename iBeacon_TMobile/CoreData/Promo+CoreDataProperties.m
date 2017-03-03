//
//  Promo+CoreDataProperties.m
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 27/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "Promo+CoreDataProperties.h"

@implementation Promo (CoreDataProperties)

+ (NSFetchRequest<Promo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Promo"];
}

@dynamic isRead;
@dynamic promoId;
@dynamic promoImageLarge;
@dynamic promoImageThumb;
@dynamic promoSyncDate;
@dynamic promoTitle;

@end
