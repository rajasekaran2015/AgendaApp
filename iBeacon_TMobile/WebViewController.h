//
//  WebViewController.h
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 27/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promo+CoreDataClass.h"

@interface WebViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) Promo *promoObj;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoader;
@property (strong, nonatomic) IBOutlet UILabel *titeLbl;
@property (strong, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property (strong, nonatomic) IBOutlet UIWebView *myWebView;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolBar;
- (IBAction)doneBtnAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backBtn;
- (IBAction)backBtnAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardBtnAction;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;
- (IBAction)refreshBtnAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *backArrowBtn;
- (IBAction)backArrowBtnAction:(id)sender;

@end
