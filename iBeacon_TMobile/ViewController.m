//
//  ViewController.m
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 23/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"
#import "Constants.h"

@interface ViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *clientName;
- (IBAction)regBtnAction:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //_clientName.text = @"RAJ";
    if(kIsRegistered){
       
        _clientName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        [self performSegueWithIdentifier:@"HomeSegue" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)regBtnAction:(id)sender {
    [kAppDelegate deleteAllPromosFromCD];
    [kAppDelegate deleteAllBeaconFromCD];
    [kAppDelegate deleteAllScheduledNotification];
    if([_clientName canResignFirstResponder])
        [_clientName resignFirstResponder];
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSDictionary *defaultsDict = @{@"name":_clientName.text, @"isRegistered":@YES};
    [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:defaultsDict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self.view setFrame:CGRectMake(0, -260, self.view.frame.size.width, self.view.frame.size.height)];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender{
    if([identifier isEqualToString:@"HomeSegue"] && _clientName.text.length > 2){
        return YES;
    }else{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle: @"Register"
                                                                            message: @"Please enter customer name."
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
                                                              style: UIAlertActionStyleDestructive
                                                            handler: nil];
        
        [controller addAction: alertAction];
        
        [self presentViewController: controller animated: YES completion: nil];
    }
    return NO;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
        HomeViewController *homeController = (HomeViewController*)segue.destinationViewController;
        homeController.regName = _clientName.text;
}

@end
