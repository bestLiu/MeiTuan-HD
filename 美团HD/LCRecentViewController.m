//
//  LCRecentViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/9.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCRecentViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "LCDealCell.h"
#import "LCDealTool.h"
#import "LCDetailViewController.h"
NSString *const reuseIdentifier = @"deal";

@interface LCRecentViewController ()<LCDealCellDelegate>
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) NSMutableArray *deals;

@end

@implementation LCRecentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"最近浏览的团购";
    self.navigationItem.leftBarButtonItem = self.backItem;
    
    self.deals = [LCDealTool recentDeals:1].copy;
    [self.collectionView registerNib:[UINib nibWithNibName:@"LCDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
}
- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        self.backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted"];
    }
    return _backItem;
}

- (NSMutableArray *)deals
{
    if (!_deals) {
        self.deals = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _deals;
}

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // cell的大小
    layout.itemSize = CGSizeMake(305, 305);
    // 设置上下左右的间距
    CGFloat inset = 15;
    layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    return [self initWithCollectionViewLayout:layout];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.deals.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LCDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.deal = self.deals[indexPath.item];
    return cell;
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LCDetailViewController *detailVc = [[LCDetailViewController alloc] init];
    detailVc.deal = self.deals[indexPath.item];
    [self presentViewController:detailVc animated:YES completion:nil];
}



- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
