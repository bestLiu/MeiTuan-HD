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



@interface LCCategoryViewController ()<LCHomeDropViewDataSource, LCHomeDropViewDelegate>

@end

@implementation LCCategoryViewController

- (void)loadView
{
    LCHomeDropView *dropView = [LCHomeDropView dropView];
    dropView.dataSource = self;
    dropView.delegate = self;
    self.view = dropView;
    self.preferredContentSize = dropView.size;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  //加载分类数据 (MJExtension使用)
//    NSString *file = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
//    NSArray *dictArray = [NSArray arrayWithContentsOfFile:file];
//    NSArray *categories = [LCCategory objectArrayWithKeyValuesArray:dictArray];
//    NSArray *categories = [LCCategory objectArrayWithFile:file];
    
}

#pragma mark -数据源
- (NSInteger) numberOfRowsInMainTable:(LCHomeDropView *)homeDropView
{
    return [LCTool categories].count;
}

- (NSString *)homeDropView:(LCHomeDropView *)homeDropView titleForRowInMainTable:(NSInteger)row
{
    LCCategory *category = [LCTool categories][row];
    return category.name;
}
- (NSString *)homeDropView:(LCHomeDropView *)homeDropView iconForRowInMainTable:(NSInteger)row
{
    LCCategory *category = [LCTool categories][row];
    return category.small_icon;
}
- (NSString *)homeDropView:(LCHomeDropView *)homeDropView selectedIconForRowInMainTable:(NSInteger)row
{
    LCCategory *category = [LCTool categories][row];
    return category.small_highlighted_icon;
}

- (NSArray *)subdataForRowInMainTable:(NSInteger)row
{
    LCCategory *category = [LCTool categories][row];
    return category.subcategories;
}

#pragma mark -代理方法
- (void)homeDropView:(LCHomeDropView *)homeDropView didSelectRowInMainTable:(int)row
{
    LCCategory *category = [LCTool categories][row];
    NSLog(@"%@",category.name);
    
    if (category.subcategories.count == 0) {//没有子类别
        //发通知
        [LCNotifiCationCenter postNotificationName:LCCategoryDidChangeNotification object:self userInfo:@{LCCategorySelectKey:category}];
    }
}
- (void)homeDropView:(LCHomeDropView *)homeDropView didSelectRowInSubTable:(int)row inMainTable:(int)mainRow
{
    LCCategory *category = [LCTool categories][mainRow];
     NSLog(@"%@____%@",category.name,category.subcategories[row]);
    
    
    //发通知
    [LCNotifiCationCenter postNotificationName:LCCategoryDidChangeNotification object:self userInfo:@{LCCategorySelectKey:category,LCSubCategorySelectKey:category.subcategories[row]}];

}

@end
