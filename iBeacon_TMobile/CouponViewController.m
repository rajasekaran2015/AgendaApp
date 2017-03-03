//
//  CouponViewController.m
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 23/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "CouponViewController.h"
#import "CouponCollectionViewCell.h"
#import "Coupon.h"
#import "WebViewController.h"
#import "CouponDetailViewController.h"
#import "Constants.h"
#import "Promo+CoreDataClass.h"
#import "Constants.h"

@interface CouponViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSString *docImgPath;
@property (strong, nonatomic) IBOutlet UIButton *menuBtn;
@property (strong, nonatomic) IBOutlet UILabel *menuLine;
@property (strong, nonatomic) IBOutlet UIButton *homeBtn;
@property (strong, nonatomic) IBOutlet UIButton *logoutBtn;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;

@property (strong, nonatomic) NSMutableArray *couponsList;

- (IBAction)menuBtnAction:(id)sender;
- (IBAction)homeBtnAction:(id)sender;
- (IBAction)logoutBtnAction:(id)sender;

@end

@implementation CouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _couponsList = [[NSMutableArray alloc] init];
    //[self initCouponItems];
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _docImgPath = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:@"PromoImages"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
    
    _dateLbl.text = [dateFormatter stringFromDate:[NSDate date]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configureView)
                                                 name:RELOAD_COUPONS_NOTIF
                                               object:nil];
    //_collectionView.backgroundColor = [UIColor blackColor];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureView];
}
- (void)configureView
{
    [_couponsList removeAllObjects];
    //Get the promos from core data
    [self loadPromosFromCoreData];
    
    //Set the new item badge value for tabbar
    int newCount = 0;
    for (Promo *promo in _couponsList) {
        if ([promo.isRead boolValue] == NO) newCount += 1;
    }
    
    [self.collectionView reloadData];
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

- (IBAction)menuBtnAction:(id)sender {
    if(_menuBtn.tag == 0){
        _menuBtn.tag = 1;
        [_menuBtn setImage:[UIImage imageNamed:@"Menu_Lines_BG"] forState:UIControlStateNormal];
        [_menuLine setHidden:NO];
         [_homeBtn setHidden:NO];
        [_logoutBtn setHidden:NO];
    }else{
        _menuBtn.tag = 0;
        [_menuBtn setImage:[UIImage imageNamed:@"Menu_Lines"] forState:UIControlStateNormal];
        [_menuLine setHidden:YES];
         [_homeBtn setHidden:YES];
        [_logoutBtn setHidden:YES];
    }
}

- (IBAction)homeBtnAction:(id)sender {
    _menuBtn.tag = 0;
    [_menuBtn setImage:[UIImage imageNamed:@"Menu_Lines"] forState:UIControlStateNormal];
    [_menuLine setHidden:YES];
    [_homeBtn setHidden:YES];
    [_logoutBtn setHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutBtnAction:(id)sender {
    _menuBtn.tag = 0;
    [_menuBtn setImage:[UIImage imageNamed:@"Menu_Lines"] forState:UIControlStateNormal];
    [_menuLine setHidden:YES];
    [_homeBtn setHidden:YES];
    [_logoutBtn setHidden:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return _couponsList.count;
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CouponCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:cell.couponImg.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(15, 15)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = cell.couponImg.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Convert rows and columns
    int row = indexPath.row % 2;
    int col = floor(indexPath.row / 2);
    // Calculate the new index in the `NSArray`
    int newIndex = ((int)indexPath.section * 2 * 2) + col + row * 2;
    
    // If the newIndex is within the range of the items array we show the cell, if not we hide it
    if(newIndex < _couponsList.count) {
        Promo *couponObj = [_couponsList objectAtIndex:newIndex];
        
        if ([couponObj.isRead boolValue] == YES)
        {
            [cell.isNewImg setHidden:YES];
        }
        else
        {
            [cell.isNewImg setHidden:NO];
        }
        cell.couponImg.layer.mask = maskLayer;
        cell.cellTitle.text = couponObj.promoTitle;
        //NSData *data = [[NSFileManager defaultManager] contentsAtPath:couponObj.promoImageThumb];
        NSString *imgPath = [NSString stringWithFormat:@"%@/%@",_docImgPath,couponObj.promoImageThumb];
        if([[NSFileManager defaultManager] fileExistsAtPath:imgPath])
        {
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:imgPath];
            cell.couponImg.image = [UIImage imageWithData:data];
        }
            else
        {
            NSLog(@"File not exits");
        }
        
        
        
        cell.hidden = NO;
    } else {
        cell.hidden = YES;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return 1;
    NSLog(@"numberOfSectionsInCollectionView : %f",ceil((float)_couponsList.count / (float)(2 * 2)));
    return ceil((float)_couponsList.count / (float)(2 * 2));
}

#pragma mark -
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    // Convert rows and columns
    int row = indexPath.row % 2;
    int col = floor(indexPath.row / 2);
    // Calculate the new index in the `NSArray`
    int newIndex = ((int)indexPath.section * 2 * 2) + col + row * 2;
    
    // If the newIndex is within the range of the items array we show the cell, if not we hide it
    if(newIndex < _couponsList.count) {
        Promo *promoObj = [_couponsList objectAtIndex:newIndex];
        
        [self markPromoReadInCoreDataAndCollection:promoObj];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: [NSBundle mainBundle]];
//        if([[promoObj promoId] isEqualToString:@"00005"]){
//            CouponDetailViewController *detailView = (CouponDetailViewController*)[mainStoryboard
//                                                                                   instantiateViewControllerWithIdentifier: @"CouponDetailClass"];
//            [detailView setPromoObj:promoObj];
//            [self.navigationController pushViewController:detailView animated:YES];
//        }else{
            WebViewController *webViewController = (WebViewController*)[mainStoryboard
                                                                        instantiateViewControllerWithIdentifier: @"WebViewClass"];
            [webViewController setPromoObj:promoObj];
            [self.navigationController pushViewController:webViewController animated:YES];
//        }
    }
}

#pragma mark -
#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
   // CGFloat picDimension = self.view.frame.size.width / 2.0f;
    return CGSizeMake(235, 272);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //CGFloat leftRightInset = self.view.frame.size.width / 14.0f;
   // return UIEdgeInsetsMake(100, 20, 50, 170);
    return UIEdgeInsetsMake(100, 20, 100, 20);
}



- (void)loadPromosFromCoreData
{
    NSManagedObjectContext *moc = [kAppDelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Promo" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    
    //    NSPredicate * predictate = [NSPredicate predicateWithFormat:@"isFemale==%@",kIsUserFemale];
    //    [request setPredicate:predictate];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"promoSyncDate" ascending:NO selector:@selector(caseInsensitiveCompare:)]]];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    if ([array count] > 0)
    {
        [_couponsList removeAllObjects];
        
        //purge the expired promos
        for (Promo *promo in array)
        {
            [_couponsList addObject:promo];
        }
    }
}

- (void)deletePromoFromCoreDataAndCollection:(Promo *)iPromo
{
    [self deletePromoFromCoreData:iPromo];
    [_couponsList removeObject:iPromo];
    [self.collectionView reloadData];
}

- (void)deletePromoFromCoreData:(Promo *)iPromo
{
    NSManagedObjectContext *moc = [kAppDelegate managedObjectContext];
    
    [moc deleteObject:iPromo];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![moc save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)markPromoReadInCoreDataAndCollection:(Promo *)iPromo
{
    if ([iPromo.isRead boolValue] == NO) {
        NSManagedObjectContext *moc = [kAppDelegate managedObjectContext];
        
        [iPromo setValue:[NSNumber numberWithBool:YES] forKey:@"isRead"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![moc save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        //Reload the corrsponsing collection view cell
        [self.collectionView reloadData];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [kAppDelegate deleteAllPromosFromCD];
        [kAppDelegate deleteAllBeaconFromCD];
        [kAppDelegate deleteAllScheduledNotification];
        [self configureView];
    }
}


@end
