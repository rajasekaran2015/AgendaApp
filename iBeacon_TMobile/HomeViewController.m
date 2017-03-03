//
//  HomeViewController.m
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 23/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"

@interface HomeViewController ()
@property (strong, nonatomic) IBOutlet UIButton *menuBtn;
@property (strong, nonatomic) IBOutlet UIButton *browseBtn;
@property (strong, nonatomic) IBOutlet UILabel *menuLine;
@property (strong, nonatomic) IBOutlet UIButton *logoutBtn;

- (IBAction)browseBtnAction:(id)sender;
- (IBAction)menuBtnAction:(id)sender;
- (IBAction)logoutBtnAction:(id)sender;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _clientName.text = _regName;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPromoList) name:@"SHOW_PROMO_LIST" object:nil];
    //[self performSelector:@selector(showPromoAlert) withObject:nil afterDelay:2.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"%@",segue.destinationViewController);
}


- (IBAction)browseBtnAction:(id)sender {
    _menuBtn.tag = 0;
    [_menuBtn setImage:[UIImage imageNamed:@"Menu_Lines"] forState:UIControlStateNormal];
    [_menuLine setHidden:YES];
    [_browseBtn setHidden:YES];
    [_logoutBtn setHidden:YES];
    [self performSegueWithIdentifier:@"CouponSegue" sender:nil];
}

- (IBAction)menuBtnAction:(id)sender {
    if(_menuBtn.tag == 0){
        _menuBtn.tag = 1;
        [_menuBtn setImage:[UIImage imageNamed:@"Menu_Lines_BG"] forState:UIControlStateNormal];
        [_menuLine setHidden:NO];
        [_browseBtn setHidden:NO];
        [_logoutBtn setHidden:NO];
    }else{
        _menuBtn.tag = 0;
        [_menuBtn setImage:[UIImage imageNamed:@"Menu_Lines"] forState:UIControlStateNormal];
        [_menuLine setHidden:YES];
        [_browseBtn setHidden:YES];
        [_logoutBtn setHidden:YES];
    }
}

- (IBAction)logoutBtnAction:(id)sender {
    _menuBtn.tag = 0;
    [_menuBtn setImage:[UIImage imageNamed:@"Menu_Lines"] forState:UIControlStateNormal];
    [_menuLine setHidden:YES];
    [_browseBtn setHidden:YES];
    [_logoutBtn setHidden:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//-(void)showPromoAlert{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_PROMO" object:nil];
//}

-(void)showPromoList{
    [self performSegueWithIdentifier:@"CouponSegue" sender:nil];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [kAppDelegate deleteAllPromosFromCD];
        [kAppDelegate deleteAllBeaconFromCD];
        [kAppDelegate deleteAllScheduledNotification];
    }
}

@end
