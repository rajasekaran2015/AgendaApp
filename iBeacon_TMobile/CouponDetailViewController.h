//
//  CouponDetailViewController.h
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 23/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promo+CoreDataClass.h"

@interface CouponDetailViewController : UIViewController

- (IBAction)backBtnAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *couponImg;
@property (strong, nonatomic) Promo *promoObj;
@end
