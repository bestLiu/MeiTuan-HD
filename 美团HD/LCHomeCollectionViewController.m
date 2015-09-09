//
//  LCHomeCollectionViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/6.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCHomeCollectionViewController.h"
#import "LCConst.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"
#import "LCHomeTopItem.h"
#import "LCCategoryViewController.h"
#import "LCDistrictViewController.h"
#import "LCSortViewController.h"
#import "LCTool.h"
#import "LCCity.h"
#import "LCSort.h"
#import "LCCategory.h"
#import "LCRegion.h"
#import "dianpingapi/DPAPI.h"
#import "LCDeal.h"
#import "LCDealCell.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UIView+AutoLayout.h"
#import "LCNavigationViewController.h"
@interface LCHomeCollectionViewController ()<DPRequestDelegate>

@property (nonatomic, weak) UIBarButtonItem *categoryItem;
@property (nonatomic, weak) UIBarButtonItem *districtItem;
@property (nonatomic, weak) UIBarButtonItem *sortItem;

@property (nonatomic, copy) NSString *selectedCityName;
@property (nonatomic, copy) NSString *selectedCategoryName;
@property (nonatomic, copy) NSString *selectedRegionName;
@property (nonatomic, strong) LCSort *selectedSort;

@property (nonatomic, strong) UIPopoverController *sortPopover;
@property (nonatomic, strong) UIPopoverController *categoryPopover;
@property (nonatomic, strong) UIPopoverController *regionPopover;

@property (nonatomic, strong) NSMutableArray *deals;//所有的团购数据
@property (nonatomic, assign) int page;
@property (nonatomic, weak) DPRequest *lastRequest;
@property (nonatomic, weak) UIImageView *nodataView;

@end

@implementation LCHomeCollectionViewController

static NSString * const reuseIdentifier = @"deal";


- (instancetype)init
{
//    self.collectionView.autoresizingMask = UIViewAutoresizingNone;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // cell的大小
    layout.itemSize = CGSizeMake(305, 305);
    // 设置上下左右的间距
    CGFloat inset = 15;
    layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    return [self initWithCollectionViewLayout:layout];
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
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view == self.collectionView.superview
    self.collectionView.backgroundColor = LCGlobalBg;
    self.collectionView.alwaysBounceVertical = NO;

    [self.collectionView registerNib:[UINib nibWithNibName:@"LCDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    //添加没有数据提醒
    UIImageView *nodataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_deals_empty"]];
    nodataView.hidden = YES;
    [self.view addSubview:nodataView];
    [nodataView autoCenterInSuperview];//直接让它在父控件中央
    self.nodataView = nodataView;
    
    //监听城市改变
    [LCNotifiCationCenter addObserver:self selector:@selector(cityChange:) name:LCCityDidSelectNotification object:nil];
    
    //监听排序改变
    [LCNotifiCationCenter addObserver:self selector:@selector(sortChange:) name:LCSortDidChangeNotification object:nil];
    
    //监听分类改变
    [LCNotifiCationCenter addObserver:self selector:@selector(categoryChange:) name:LCCategoryDidChangeNotification object:nil];
    
    //监听区域改变
    [LCNotifiCationCenter addObserver:self selector:@selector(regionChange:) name:LCRegionDidChangeNotification object:nil];
    
    
    [self setupLeftNav];
    [self setupRightNav];
    
    //添加上拉刷新控件
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
    [self.collectionView addHeaderWithTarget:self action:@selector(loadNewDeals)];
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
    //城市
    params[@"page"] = @(self.page);
    params[@"city"] = self.selectedCityName;
    params[@"limit"] = @5;
    if (self.selectedCategoryName) {
        params[@"category"] = self.selectedCategoryName;
    }
    if (self.selectedSort) {
        params[@"sort"] = @(self.selectedSort.value);
    }
    if (self.selectedRegionName) {
        params[@"region"] = self.selectedRegionName;
    }
    NSLog(@"parameters -->>> %@",params);
    
    
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

- (void)setupLeftNav
{
    // 1、logo
    UIBarButtonItem *logoTopItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_meituan_logo"] style:UIBarButtonItemStylePlain target:self action:nil];
    logoTopItem.enabled = NO;//不是UI控件没有userInteractionEnable
    
    //2、类别
    LCHomeTopItem *categoryTopItem = [LCHomeTopItem item];
    [categoryTopItem addTarget:self action:@selector(categoryClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    self.categoryItem = categoryItem;
    
    //3、地区
    LCHomeTopItem *districtTopItem = [LCHomeTopItem item];
    [districtTopItem addTarget:self action:@selector(districtClick)];
    UIBarButtonItem *districtItem = [[UIBarButtonItem alloc] initWithCustomView:districtTopItem];
    self.districtItem = districtItem;
    
    //4、排序
    LCHomeTopItem *sortTopItem = [LCHomeTopItem item];
    [sortTopItem setTitle:@"排序"];
    [sortTopItem setIcon:@"icon_sort" highlightIcon:@"icon_sort_highlighted"];
    [sortTopItem addTarget:self action:@selector(sortClick)];
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortTopItem];
    self.sortItem = sortItem;
    
    self.navigationItem.leftBarButtonItems = @[logoTopItem,categoryItem,districtItem,sortItem];
}
- (void)setupRightNav
{
    UIBarButtonItem *mapItem = [UIBarButtonItem itemWithTarget:nil action:nil image:@"icon_map" highImage:@"icon_map_highlighted"];
    UIBarButtonItem *searchItem = [UIBarButtonItem itemWithTarget:self action:@selector(searchClick) image:@"icon_search" highImage:@"icon_search_highlighted"];
    mapItem.customView.width = 60;
    searchItem.customView.width = 60;
    self.navigationItem.rightBarButtonItems = @[mapItem,searchItem];
}

#pragma mark - 顶部item点击事件
- (void)categoryClick
{
    //显示分类菜单
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:[[LCCategoryViewController alloc] init]];
    [popover presentPopoverFromBarButtonItem:self.categoryItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.categoryPopover = popover;
}
- (void)districtClick
{
    LCDistrictViewController *districtVc = [[LCDistrictViewController alloc] init];
    
    if (self.selectedCityName) {
    LCCity *city = [[[LCTool cities] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@",self.selectedCityName]] firstObject];
        
    //获得当前选中城市的区域
    districtVc.regions = city.regions;

    }
        //显示区域菜单
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:districtVc];
    [popover presentPopoverFromBarButtonItem:self.districtItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.regionPopover = popover;
    districtVc.popover = popover;
}
- (void)sortClick
{
    //显示排序菜单
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:[[LCSortViewController alloc] init]];
    [popover presentPopoverFromBarButtonItem:self.sortItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.sortPopover = popover;
}
- (void)searchClick
{
    LCNavigationViewController *nav = [[LCNavigationViewController alloc] init];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //计算cell 的内边距
    [self viewWillTransitionToSize:CGSizeMake(self.collectionView.size.width, 0) withTransitionCoordinator:nil];
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"self.deals.count %d",self.deals.count);
    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    LCDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.deal = self.deals[indexPath.item];
    return cell;
}

#pragma mark - 首页监听城市改变
- (void)cityChange:(NSNotification *)noti
{
    self.selectedCityName = noti.userInfo[LCCitySelectCityKey];
    
    // 1更换区域item的文字
    LCHomeTopItem *topItem = (LCHomeTopItem *)self.districtItem.customView;
    [topItem setTitle:[NSString stringWithFormat:@"%@",_selectedCityName]];
    [topItem setSubtitle:nil];
    
    
    // 2刷新表格数据
    [self.collectionView headerBeginRefreshing];
}

- (void)sortChange:(NSNotification *)noti
{
    LCSort *sort = noti.userInfo[LCSortSelectKey];
    // 1更换排序item的文字
    LCHomeTopItem *topItem = (LCHomeTopItem *)self.sortItem.customView;
    [topItem setSubtitle:sort.label];
    
    self.selectedSort = sort;
    //刷新表格数据
    [self.collectionView headerBeginRefreshing];
    
    //关闭POPover
    [self.sortPopover dismissPopoverAnimated:YES];

    
}


- (void)categoryChange:(NSNotification *)noti
{
    LCCategory *category = noti.userInfo[LCCategorySelectKey];
    NSString *subcategoryName = noti.userInfo[LCSubCategorySelectKey];
    
    //改变顶部文字
    LCHomeTopItem *topItem = (LCHomeTopItem *)self.categoryItem.customView;
    [topItem setIcon:category.icon highlightIcon:category.highlighted_icon];
    [topItem setTitle:category.name];
    [topItem setSubtitle:subcategoryName];
    
    if (subcategoryName == nil ||[subcategoryName isEqualToString:@"全部"]) {//点击了没有子分类的类别
        self.selectedCategoryName = category.name;
    }else{
        self.selectedCategoryName = subcategoryName;
    }
    
    if ([self.selectedCategoryName isEqualToString:@"全部分类"]) {
        self.selectedCategoryName = nil;
    }
    
    //刷新表格数据
    [self.collectionView headerBeginRefreshing];
    
    //关闭popvoer
    [self.categoryPopover dismissPopoverAnimated:YES];
    
}

- (void)regionChange:(NSNotification *)noti
{
    LCRegion *region = noti.userInfo[LCRegionSelectKey];
    NSString *subRegionName = noti.userInfo[LCSubRegionSelectKey];
    
    //改变顶部文字
    LCHomeTopItem *topItem = (LCHomeTopItem *)self.districtItem.customView;
    [topItem setTitle:[NSString stringWithFormat:@"%@ - %@",self.selectedCityName,region.name]];
    [topItem setSubtitle:subRegionName];
    if (subRegionName == nil ||[subRegionName isEqualToString:@"全部"]) {
        self.selectedRegionName = region.name;
    }else{
        self.selectedRegionName = subRegionName;
    }
    if ([self.selectedRegionName isEqualToString:@"全部"]) {
        self.selectedRegionName = nil;
    }
    
    //刷新表格数据
    [self.collectionView headerBeginRefreshing];
    
    //关闭popvoer
    [self.regionPopover dismissPopoverAnimated:YES];
    
}



- (void)dealloc
{
    [LCNotifiCationCenter removeObserver:self];
}

@end
