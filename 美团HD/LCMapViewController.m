//
//  LCMapViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/16.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCMapViewController.h"
#import "UIBarButtonItem+Extension.h"
#import <Mapkit/MapKit.h>
#import "dianpingapi/DPAPI.h"
#import "LCBusiness.h"
#import "LCDeal.h"
#import "MJExtension.h"
#import "LCDealAnnotation.h"
#import "LCHomeTopItem.h"
#import "LCCategoryViewController.h"



@interface LCMapViewController ()<MKMapViewDelegate, DPRequestDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) CLGeocoder *coder;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, strong) UIPopoverController *categoryPopover;
@property (nonatomic, weak) UIBarButtonItem *categoryItem;
@property (nonatomic, copy) NSString *selectedCategoryName;
@property (nonatomic, strong) DPRequest *lastRequest;

@end

@implementation LCMapViewController

- (CLGeocoder *)coder
{
    if (!_coder) {
        self.coder = [[CLGeocoder alloc] init];
    }
    return _coder;
}
- (CLLocationManager *)manager
{
    if (!_manager) {
        self.manager = [[CLLocationManager alloc] init];
    }
    return _manager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"地图";
     UIBarButtonItem *backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted"];

    LCHomeTopItem *categoryTopItem = [LCHomeTopItem item];
    [categoryTopItem addTarget:self action:@selector(categoryClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    self.categoryItem = categoryItem;
    
    self.navigationItem.leftBarButtonItems = @[backItem,categoryItem];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue]>=8.0) {
        [self.manager requestWhenInUseAuthorization];
    }
    
    //设置地图跟踪用户的位置
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    //标准地图
//    self.mapView.mapType = MKMapTypeStandard;
    
    //设置代理
    self.mapView.delegate = self;
    
    
    //监听分类改变
    [LCNotifiCationCenter addObserver:self selector:@selector(categoryChange:) name:LCCategoryDidChangeNotification object:nil];
    
}

- (void)categoryClick
{
    //显示分类菜单
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:[[LCCategoryViewController alloc] init]];
    [popover presentPopoverFromBarButtonItem:self.categoryItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.categoryPopover = popover;
}

- (void)categoryChange:(NSNotification *)noti
{
    //关闭popover
    [self.categoryPopover dismissPopoverAnimated:YES];
    
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
    
    //移除所有大头针
    [self.mapView removeAnnotations:self.mapView.annotations];

    //发送请求给服务器
    [self mapView:self.mapView regionDidChangeAnimated:YES];
    
}

#pragma mark -MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    userLocation.title = @"不是当前位置";
    userLocation.subtitle = @"才怪";
    //让地图显示用户所在位置
    MKCoordinateSpan span = MKCoordinateSpanMake(0.25, 0.25);//地图经纬度跨度，跨度越小，地图显示的位置越好。
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    [mapView setRegion:region];
    
    //知道经纬度 ---->>>>> 获取城市名(地理反编码)
    [self.coder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks.count == 0) return;
        
        CLPlacemark *pm = [placemarks firstObject];
        NSLog(@"地理反编码--->>> %@---%@",pm.locality,pm.addressDictionary);

        NSString *city = pm.locality ? pm.locality : pm.addressDictionary[@"State"];
        self.city = [city substringToIndex:city.length - 1];
        
        //第一次进来就发送请求给服务器
        [self mapView:self.mapView regionDidChangeAnimated:YES];
        
    }];

    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.city == nil) {
        return;
    }
    //当前地图现实的区域--->>>> mapView.region
    
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"city"] = @"成都";
    if (self.selectedCategoryName) {
        params[@"category"] = self.selectedCategoryName;
    }
    params[@"latitude"] = @(mapView.region.center.latitude);
    params[@"longitude"] = @(mapView.region.center.longitude);
    params[@"radius"] = @(5000);
    NSLog(@"params----->>>>>> %@",params);
    NSString *urlString = @"v1/deal/find_deals";
   self.lastRequest = [api requestWithURL:urlString params:params delegate:self];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(LCDealAnnotation *)annotation
{
    NSLog(@"annotation %@",annotation);
    // 返回nil 表示是刚开始蓝色的大头针
    if (![annotation isKindOfClass:[LCDealAnnotation class]]) return nil;
    
    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"deal"];
    if (annoView == nil) {
        annoView = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@"deal"];
    }
    //设置模型(位置、标题、子标题)
    annoView.annotation = annotation;
    
    //设置图片
    annoView.image = [UIImage imageNamed:annotation.icon];
    annoView.canShowCallout = YES;
    
    return annoView;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    CLLocation *location = [locations firstObject];
//    
//    [self.coder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//        if (error || placemarks.count == 0) return;
//        
//        CLPlacemark *pm = [placemarks firstObject];
//        NSLog(@"地理反编码--->>> %@---%@",pm.locality,pm.addressDictionary);
//        NSString *urlString = @"v1/deal/find_deals";
//        DPAPI *api = [[DPAPI alloc] init];
//        NSMutableDictionary *params = [NSMutableDictionary dictionary];
//        NSString *city = pm.locality ? pm.locality : pm.addressDictionary[@"state"];
//        city = [city substringToIndex:city.length - 1];
//        params[@"city"] = @"成都";
//        params[@"latitude"] = @(location.coordinate.latitude);
//        params[@"longitude"] = @(location.coordinate.longitude);
//        params[@"radius"] = @(5000);
//        
//        [api requestWithURL:urlString params:params delegate:self];
//        
//    }];

}


#pragma mark - 大众点评请求
- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (request != self.lastRequest) {
        return;//不是最后一次请求直接返回
    }
    
    NSArray *deals = [LCDeal objectArrayWithKeyValuesArray:result[@"deals"]];
    for (LCDeal *deal in deals) {
        
        // 获得团购所属的类型
        LCCategory *category = [LCTool categoryWithDeal:deal];
        
        for (LCBusiness *business in deal.businesses) {
            LCDealAnnotation *anno = [[LCDealAnnotation alloc] init];
            anno.coordinate = CLLocationCoordinate2DMake(business.latitude, business.longitude);
            anno.title = business.name;
            anno.subtitle = deal.title;
            anno.icon = category.map_icon;
            
            if ([self.mapView.annotations containsObject:anno]) break;
            
            [self.mapView addAnnotation:anno];
        }
    }
  
}



- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    
}









- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
