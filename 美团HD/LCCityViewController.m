//
//  LCCityViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/7.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCCityViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "LCCity.h"
#import "MJExtension.h"
#import "LCcityGroup.h"
#import "Masonry.h"
@interface LCCityViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *cityGroups;
@property (nonatomic, strong) UIView *coverView;

@end

@implementation LCCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"切换城市";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(close) image:@"btn_navigation_close" highImage:@"btn_navigation_close_hl"];
    
    self.tableView.sectionIndexColor = [UIColor cyanColor];
    //加载城市数据
    self.cityGroups = [LCcityGroup objectArrayWithFilename:@"cityGroups.plist"];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 表的数据源
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.cityGroups.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    LCcityGroup *group = self.cityGroups[section];
    return group.cities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    LCcityGroup *group = self.cityGroups[indexPath.section];
    
    cell.textLabel.text = group.cities[indexPath.row];
    
    return cell;
}

#pragma mark - 表代理

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    LCcityGroup *group = self.cityGroups[section];
    return group.title;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//    NSMutableArray *titles = [NSMutableArray array];
//    for (LCcityGroup *group in self.cityGroups) {
//        [titles addObject:group.title];
//    }
    
//    kvc返回装有title数组
    return [self.cityGroups valueForKeyPath:@"title"];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // 1、隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    
    // 2、显示遮盖
    self.coverView = [[UIView alloc] init];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.alpha = 0.5;
    [_coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:searchBar action:@selector(resignFirstResponder)]];
    [self.view addSubview:_coverView];
    
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tableView.mas_left);
        make.right.equalTo(self.tableView.mas_right);
        make.top.equalTo(self.tableView.mas_top);
        make.bottom.equalTo(self.tableView.mas_bottom);
        
    }];
    
    // 3、修改搜索框的背景图片
    searchBar.backgroundImage = [UIImage imageNamed:@"bg_login_textfield_hl"];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    // 1、显示导航栏
    self.navigationController.navigationBarHidden = NO;
    
    // 2、移除遮盖
    [_coverView removeFromSuperview];
    
    // 3、修改搜索框的背景图片
    searchBar.backgroundImage = [UIImage imageNamed:@"bg_login_textfield"];
}

@end
