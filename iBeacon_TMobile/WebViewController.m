//
//  WebViewController.m
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 27/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "WebViewController.h"

/*
@interface UIView (RenderToImage)

- (UIImage *)imageByRenderingView;

@end

@implementation UIView (RenderViewToImage)

- (UIImage *)imageByRenderingView
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end
*/

@interface WebViewController (){
    UIImage *screenShotImg;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titeLbl.text = _promoObj.promoTitle;
    _backBtn.enabled = NO;
    _forwardBtn.enabled = NO;
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:[NSString stringWithFormat:@"/TMobile/%@",_promoObj.promoTitle]]];
    [_myWebView loadRequest:[NSURLRequest requestWithURL:url]];
    //[_myWebView setContentMode:UIViewContentModeScaleToFill];
    [_myWebView setScalesPageToFit:YES];
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    //[_myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self isBeingPresented]) {
        // being presented
        self.backArrowBtn.hidden = YES;
        self.topToolBar.hidden = NO;
    } else if ([self isMovingToParentViewController]) {
        // being pushed
        self.topToolBar.hidden = YES;
        self.backArrowBtn.hidden = NO;
    } else {
        // simply showing again because another VC was dismissed
        self.backArrowBtn.hidden = YES;
        self.topToolBar.hidden = NO;
    }
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
#pragma mark - UIWebview Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad");
    [_activityLoader startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad");
    [_activityLoader stopAnimating];
    if([_myWebView canGoBack])
        _backBtn.enabled = YES;
    else
        _backBtn.enabled = NO;
    
    if([_myWebView canGoForward])
        _forwardBtn.enabled = YES;
    else
        _forwardBtn.enabled = NO;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didFailLoadWithError : %@",[error description]);
    [_activityLoader stopAnimating];
}


- (IBAction)doneBtnAction:(id)sender {
    /*
    screenShotImg = [self.view imageByRenderingView];
    NSData *pngData = UIImagePNGRepresentation(screenShotImg);
    NSError *errorPtr =nil;
    [pngData writeToFile:_promoObj.promoImageThumb options:NSDataWritingAtomic error:&errorPtr];
    NSLog(@"errorPtr : %@",errorPtr);
    errorPtr = nil;
    [pngData writeToFile:_promoObj.promoImageLarge options:NSDataWritingAtomic error:&errorPtr];
    NSLog(@"errorPtr : %@",errorPtr);
    */
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)backBtnAction:(id)sender {
    if([_myWebView canGoBack])
        [_myWebView goBack];
}
- (IBAction)refreshBtnAction:(id)sender {
    if([_myWebView canGoForward])
        [_myWebView goForward];
}

- (IBAction)backArrowBtnAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
