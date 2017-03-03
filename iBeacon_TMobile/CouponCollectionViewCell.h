//
//  CouponCollectionViewCell.h
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 23/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *couponBGImg;
@property (strong, nonatomic) IBOutlet UIImageView *couponImg;
@property (strong, nonatomic) IBOutlet UIImageView *isNewImg;
@property (strong, nonatomic) IBOutlet UILabel *cellTitle;

@end
