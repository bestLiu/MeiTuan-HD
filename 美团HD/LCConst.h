#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"

#ifdef DEBUG
#define LCLog(...) NSLog(__VA_ARGS__)
#else
#define LCLog(...)
#endif


#define LCColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define LCGlobalBg LCColor(230, 230, 230)
#define LCNotifiCationCenter [NSNotificationCenter defaultCenter]

extern NSString *const LCCityDidSelectNotification;
extern NSString *const LCCitySelectCityKey;

extern NSString *const LCSortDidChangeNotification;
extern NSString *const LCSortSelectKey;

extern NSString *const LCCategoryDidChangeNotification;
extern NSString *const LCCategorySelectKey;
extern NSString *const LCSubCategorySelectKey;

extern NSString *const LCRegionDidChangeNotification;
extern NSString *const LCRegionSelectKey;
extern NSString *const LCSubRegionSelectKey;

extern NSString *const LCCollectStateDidChangeNotification;
extern NSString *const LCIsCollectKey;
extern NSString *const LCCollectDealKey;
