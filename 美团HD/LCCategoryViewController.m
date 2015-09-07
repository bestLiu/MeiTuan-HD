//
//  LCCategoryViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/7.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCCategoryViewController.h"
#import "LCHomeDropView.h"
#import "LCCategory.h"
#import "MJExtension.h"
#import "UIView+Extension.h"


@interface LCCategoryViewController ()

@end

@implementation LCCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  //加载分类数据
//    NSString *file = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
//    NSArray *dictArray = [NSArray arrayWithContentsOfFile:file];
//    NSArray *categories = [LCCategory objectArrayWithKeyValuesArray:dictArray];
//    NSArray *categories = [LCCategory objectArrayWithFile:file];
    
    NSArray *categories = [LCCategory objectArrayWithFilename:@"categories.plist"];
    LCHomeDropView *dropView = [LCHomeDropView dropView];
    
    dropView.categroies = categories;
    [self.view addSubview:dropView];
    self.preferredContentSize = dropView.size;
}




@end
