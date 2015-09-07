//
//  LCDistrictViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/7.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCDistrictViewController.h"
#import "LCHomeDropView.h"
#import "Masonry.h"
#import "UIView+Extension.h"
#import "LCCityViewController.h"
#import "LCNavigationViewController.h"

@interface LCDistrictViewController ()
- (IBAction)changeCity;

@end

@implementation LCDistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *titleView =  [self.view.subviews firstObject];
    NSLog(@" %@",titleView);
    
    LCHomeDropView *dropView = [LCHomeDropView dropView];
    dropView.autoresizingMask = UIViewAutoresizingNone;
    dropView.y = titleView.height;
    [self.view addSubview:dropView];
    

    self.preferredContentSize = CGSizeMake(dropView.width, CGRectGetMaxY(dropView.frame));

}


/**
 *  切换城市
 */
- (IBAction)changeCity {
    LCCityViewController *cityVc = [[LCCityViewController alloc] init];
    LCNavigationViewController *nav = [[LCNavigationViewController alloc] initWithRootViewController:cityVc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
    
}
@end
