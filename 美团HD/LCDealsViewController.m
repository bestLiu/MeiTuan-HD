//
//  LCDealsViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/9.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCDealsViewController.h"
#import "MJRefresh.h"
#import "dianpingapi/DPAPI.h"
#import "LCDealCell.h"
#import "UIView+AutoLayout.h"
#import "UIView+Extension.h"
#import "SVProgressHUD.h"
#import "MJExtension.h"
#import "LCDetailViewController.h"

@interface LCDealsViewController ()<DPRequestDelegate>

@property (nonatomic, weak) DPRequest *lastRequest;
@property (nonatomic, strong) NSMutableArray *deals;//所有的团购数据
@property (nonatomic, weak) UIImageView *nodataView;
@property (nonatomic, assign) int page;


@end

@implementation LCDealsViewController

static NSString * const reuseIdentifier = @"deal";
- (instancetype)init
{
    //    self.collectionView.autoresizingMask = UIViewAutoresizingNone;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // cell的大小
    layout.itemSize = CGSizeMake(305, 305);
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.collectionView.backgroundColor = LCGlobalBg;
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LCDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];

    
    //添加没有数据提醒
    UIImageView *nodataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_deals_empty"]];
    nodataView.hidden = YES;
    [self.view addSubview:nodataView];
    [nodataView autoCenterInSuperview];//直接让它在父控件中央
    self.nodataView = nodataView;
    
    
    //添加上/下拉刷新控件
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
    [self.collectionView addHeaderWithTarget:self action:@selector(loadNewDeals)];
}
- (NSMutableArray *)deals
{
    if (!_deals) {
        self.deals = [[NSMutableArray alloc] init];
    }
    return _deals;
}
//当屏幕旋转，控制器view的尺寸发生改变时调用
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    int cols = (size.width == 1024)?3:2;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGFloat inset = (size.width - cols * layout.itemSize.width)/(cols + 1);
    layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    
    //设置每一行之间的间距
    layout.minimumLineSpacing = inset;
}

#pragma mark 跟服务器交互
- (void)loadMoreDeals
{
    self.page ++;
    [self loadDeals];
}
- (void)loadNewDeals
{
    self.page = 1;
    [self loadDeals];
}
- (void)loadDeals
{
    NSString *urlString = @"v1/deal/find_deals";
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //调用子类实现的方法
    [self setupParams:params];
       
    self.lastRequest = [api requestWithURL:urlString params:params delegate:self];
}


#pragma mark 请求代理
- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    //请求失败
    NSLog(@"请求失败--->>> %@",error);
    // 提醒用户失败
    [SVProgressHUD showErrorWithStatus:@"网络错误,请稍候再试"];
    
    // 结束上/下拉刷新
    [self.collectionView footerEndRefreshing];
    [self.collectionView headerEndRefreshing];
    
    //如果是上拉刷新失败
    if (self.page > 1) {
        self.page -- ;
    }
    
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (request != self.lastRequest) return; //如果不是最后一个请求 就结束
    
    //1、取出团购的字典数组
    NSArray *deals = [LCDeal objectArrayWithKeyValuesArray:result[@"deals"]];
    if (self.page == 1) {//第一页数据,清除之前的旧数据
        [self.deals removeAllObjects];
    }
    [self.deals addObjectsFromArray:deals];
    
    //2 、刷新表格
    [self.collectionView reloadData];
    
    //3 、结束上/下拉加载
    [self.collectionView footerEndRefreshing];
    [self.collectionView headerEndRefreshing];
    
    //4 、控制尾部刷新控件的显示和隐藏.总数和数组的长度相等的时候影藏上拉刷新
    self.collectionView.footerHidden = [result[@"total_count"] integerValue] == self.deals.count;
    
    //5 、控制没有数据的提醒
    self.nodataView.hidden = self.deals.count != 0;
}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //计算cell 的内边距
    [self viewWillTransitionToSize:CGSizeMake(self.collectionView.size.width, 0) withTransitionCoordinator:nil];
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    LCDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.deal = self.deals[indexPath.item];
    
    return cell;
}
#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LCDetailViewController *detailVc = [[LCDetailViewController alloc] init];
    detailVc.deal = self.deals[indexPath.item];
    [self presentViewController:detailVc animated:YES completion:nil];

}

@end
