//
//  CouponDetailViewController.m
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 23/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "CouponDetailViewController.h"

@interface CouponDetailViewController ()
@property (strong, nonatomic) NSString *docImgPath;
@property (strong, nonatomic) IBOutlet UILabel *pageTitle;

@end

@implementation CouponDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _docImgPath = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:@"PromoImages"]];
    NSString *imgPath = [NSString stringWithFormat:@"%@/%@",_docImgPath,_promoObj.promoImageLarge];
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:imgPath];
    [_couponImg setImage:[UIImage imageWithData:data]];

    //    _couponImg.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:_promoObj.promoImageLarge]];
    _pageTitle.text = _promoObj.promoTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
