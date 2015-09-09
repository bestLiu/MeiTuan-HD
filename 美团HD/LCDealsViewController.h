//
//  LCDealsViewController.h
//  美团HD
//
//  Created by mac1 on 15/9/9.
//  Copyright (c) 2015年 BNDK. All rights reserved.
// 团购列表控制器,用作父类

#import <UIKit/UIKit.h>

@interface LCDealsViewController : UICollectionViewController

/**
 *  交给子类去实现，设置请求参数
 *
 *  @param params 参数
 */
- (void)setupParams:(NSMutableDictionary *)params;

@end
