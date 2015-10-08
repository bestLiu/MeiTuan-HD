//
//  LCHomeCollectionViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/6.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCHomeCollectionViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"
#import "LCHomeTopItem.h"
#import "LCCategoryViewController.h"
#import "LCDistrictViewController.h"
#import "LCSortViewController.h"
#import "LCCity.h"
#import "LCSort.h"
#import "LCCategory.h"
#import "LCRegion.h"
#import "MJRefresh.h"
#import "LCSearchCollectionViewController.h"
#import "AwesomeMenu.h"
#import "UIView+AutoLayout.h"
#import "LCNavigationViewController.h"
#import "LCRecentViewController.h"
#import "LCCollectViewController.h"
#import "LCMapViewController.h"
#import "MBProgessHUD/MBProgressHUD+LC.h"
#import <CoreLocation/CoreLocation.h>

@interface LCHomeCollectionViewController ()<AwesomeMenuDelegate,CLLocationManagerDelegate,UIAlertViewDelegate>
{
    CLLocationManager *_locationManager;
}


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
@property (nonatomic, assign) int page;

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, copy) NSString *locationCityName;


@end

@implementation LCHomeCollectionViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        [self setupNotificaion];
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view == self.collectionView.superview
    
    [self setupLeftNav];
    [self setupRightNav];
    
    //创建AweSomeMenu
    [self setAwesomeMenu];
    
    //开启定位
    [self setupLocation];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [LCNotifiCationCenter removeObserver:self];
}

- (void)setupLocation
{
    [MBProgressHUD showMessage:@"正在获取位置信息请稍候..." toView:self.view];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    //设置定位精度
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //定位频率,每隔多少米定位一次
    CLLocationDistance distance = 1000.0;//1000米定位一次
    _locationManager.distanceFilter=distance;
    //启动跟踪定位
    [_locationManager startUpdatingLocation];
    _geocoder = [[CLGeocoder alloc] init];

}

- (void)setupNotificaion
{
    
    //监听城市改变
    [LCNotifiCationCenter addObserver:self selector:@selector(cityChange:) name:LCCityDidSelectNotification object:nil];
    
    //监听排序改变
    [LCNotifiCationCenter addObserver:self selector:@selector(sortChange:) name:LCSortDidChangeNotification object:nil];
    
    //监听分类改变
    [LCNotifiCationCenter addObserver:self selector:@selector(categoryChange:) name:LCCategoryDidChangeNotification object:nil];
    
    //监听区域改变
    [LCNotifiCationCenter addObserver:self selector:@selector(regionChange:) name:LCRegionDidChangeNotification object:nil];
}

- (void)setAwesomeMenu
{
    // 1.中间的item
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_pathMenu_background_highlighted"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_normal"] highlightedContentImage:nil];
    
    // 2.周边的item
    AwesomeMenuItem *item0 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_highlighted"]];
    AwesomeMenuItem *item1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_highlighted"]];
    AwesomeMenuItem *item2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_highlighted"]];
    AwesomeMenuItem *item3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_more_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_more_highlighted"]];
    
    NSArray *items = @[item0, item1, item2, item3];
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:CGRectZero startItem:startItem optionMenus:items];
    // 设置菜单的活动范围
    menu.menuWholeAngle = M_PI_2;
    // 设置开始按钮的位置
    menu.startPoint = CGPointMake(50, 150);
    // 设置代理
    menu.delegate = self;
    // 不要旋转中间按钮
    menu.rotateAddButton = NO;
    [self.view addSubview:menu];
    
    // 设置菜单永远在左下角
    [menu autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [menu autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [menu autoSetDimensionsToSize:CGSizeMake(200, 200)];//设置尺寸
}

- (void)setupLeftNav
{
    // 1、logo
    UIBarButtonItem *logoTopItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_meituan_logo"] style:UIBarButtonItemStylePlain target:self action:nil];
    logoTopItem.enabled = NO;//不是UI控件没有userInteractionEnable
    
    //2、类别
    LCHomeTopItem *categoryTopItem = [LCHomeTopItem item];
    [categoryTopItem setTitle:@"全部分类"];
    [categoryTopItem setIcon:@"icon_category_-1" highlightIcon:@"icon_category_highlighted_-1"];
    [categoryTopItem addTarget:self action:@selector(categoryClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    self.categoryItem = categoryItem;
    
    //3、地区
    LCHomeTopItem *districtTopItem = [LCHomeTopItem item];
    [districtTopItem setTitle:@"城市"];
    [districtTopItem addTarget:self action:@selector(districtClick)];
    UIBarButtonItem *districtItem = [[UIBarButtonItem alloc] initWithCustomView:districtTopItem];
    self.districtItem = districtItem;
    
    //4、排序
    LCHomeTopItem *sortTopItem = [LCHomeTopItem item];
    [sortTopItem setTitle:@"排序"];
    [sortTopItem setSubtitle:@"默认排序"];
    [sortTopItem setIcon:@"icon_sort" highlightIcon:@"icon_sort_highlighted"];
    [sortTopItem addTarget:self action:@selector(sortClick)];
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortTopItem];
    self.sortItem = sortItem;
    
    self.navigationItem.leftBarButtonItems = @[logoTopItem,categoryItem,districtItem,sortItem];
}
- (void)setupRightNav
{
    UIBarButtonItem *mapItem = [UIBarButtonItem itemWithTarget:self action:@selector(mapItemClick) image:@"icon_map" highImage:@"icon_map_highlighted"];
    UIBarButtonItem *searchItem = [UIBarButtonItem itemWithTarget:self action:@selector(searchClick) image:@"icon_search" highImage:@"icon_search_highlighted"];
    mapItem.customView.width = 60;
    searchItem.customView.width = 60;
    self.navigationItem.rightBarButtonItems = @[mapItem,searchItem];
}

#pragma mark - 顶部item点击事件
- (void)categoryClick
{
    //显示分类菜单
    if (!self.selectedCityName) {
        [MBProgressHUD showError:@"请先选择城市" toView:self.view];
        return;
    }
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

- (void)mapItemClick
{
    LCNavigationViewController *nav = [[LCNavigationViewController alloc] initWithRootViewController:[[LCMapViewController alloc] init]];
    [self presentViewController:nav animated:YES completion:nil];
    
}
- (void)searchClick
{
    if (self.selectedCityName) {
        LCSearchCollectionViewController *searchController = [[LCSearchCollectionViewController alloc] init];
        searchController.cityName = self.selectedCityName;
        LCNavigationViewController *nav = [[LCNavigationViewController alloc] initWithRootViewController:searchController];
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        [MBProgressHUD showError:@"请选择城市" toView:self.view];
    }
    
}


#pragma mark - 首页监听改变
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

#pragma mark -调用父类的方法设置参数
- (void)setupParams:(NSMutableDictionary *)params
{
    //城市
    params[@"page"] = @(self.page);
    params[@"city"] = self.selectedCityName;
    params[@"limit"] = @9;
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
    
}
#pragma mark - AwesomeMenuDelegate
- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
    // 替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_cross_normal"];
}

- (void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu
{
    // 替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
}

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    // 替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    
    switch (idx) {
        case 0: { // 收藏
            LCNavigationViewController *nav = [[LCNavigationViewController alloc] initWithRootViewController:[[LCCollectViewController alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
            
        case 1: { // 最近访问记录
            LCNavigationViewController *nav = [[LCNavigationViewController alloc] initWithRootViewController:[[LCRecentViewController alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark 跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];//取出第一个位置
    CLLocationCoordinate2D coordinate = location.coordinate;//位置坐标
    [_locationManager stopUpdatingLocation];
    [self getAddressByLatitude:coordinate.latitude longitude:coordinate.longitude];
}
#pragma mark 地理反编码
-(void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    //反地理编码
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        if (placemark) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.locationCityName = placemark.locality ? placemark.locality : placemark.addressDictionary[@"State"];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"网络繁忙，请稍候再试" toView:self.view];
            return;
        }
        NSString *msg = [NSString stringWithFormat:@"定位到当前位置：%@是否切换?",_locationCityName];
        [[[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil] show];
    }];
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //去掉直辖城市后面的“市”
        NSString *cityName = [self.locationCityName containsString:@"市"]?[_locationCityName substringWithRange:NSMakeRange(0, _locationCityName.length - 1)]:self.locationCityName;
        [LCNotifiCationCenter postNotificationName:LCCityDidSelectNotification object:self userInfo:@{LCCitySelectCityKey:cityName}];
    }
}

- (void)dealloc
{
    [LCNotifiCationCenter removeObserver:self];
}

@end
