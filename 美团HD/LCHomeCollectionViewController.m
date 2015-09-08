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
@interface LCHomeCollectionViewController ()

@property (nonatomic, weak) UIBarButtonItem *categoryItem;
@property (nonatomic, weak) UIBarButtonItem *districtItem;
@property (nonatomic, weak) UIBarButtonItem *sortItem;

@property (nonatomic, copy) NSString *selectedCityName;

@property (nonatomic, strong) UIPopoverController *sortPopover;
@property (nonatomic, strong) UIPopoverController *categoryPopover;
@property (nonatomic, strong) UIPopoverController *regionPopover;


@end

@implementation LCHomeCollectionViewController

static NSString * const reuseIdentifier = @"Cell";


- (instancetype)init
{
    UICollectionViewLayout *viewLayout = [[UICollectionViewLayout alloc] init];
    return [self initWithCollectionViewLayout:viewLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view == self.collectionView.superview
    self.collectionView.backgroundColor = LCGlobalBg;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
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
    UIBarButtonItem *searchItem = [UIBarButtonItem itemWithTarget:nil action:nil image:@"icon_search" highImage:@"icon_search_highlighted"];
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
        
        NSLog(@"city--->>>%@",city.regions);
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
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
    
    
    // 2
#warning TODO

    
}

- (void)sortChange:(NSNotification *)noti
{
    LCSort *sort = noti.userInfo[LCSortSelectKey];
    // 1更换排序item的文字
    LCHomeTopItem *topItem = (LCHomeTopItem *)self.sortItem.customView;
    [topItem setSubtitle:sort.label];
    
    //刷新表格数据
    
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
    
    //刷新表格数据
    
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
    
    //刷新表格数据
    
    //关闭popvoer
    [self.regionPopover dismissPopoverAnimated:YES];
}

- (void)dealloc
{
    [LCNotifiCationCenter removeObserver:self];
}

@end
