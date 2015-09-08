//
//  LCNavigationViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/6.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCNavigationViewController.h"

@interface LCNavigationViewController ()

@end

@implementation LCNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


+ (void)initialize
{
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar_normal"] forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
