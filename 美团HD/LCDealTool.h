//
//  LCDealTool.h
//  美团HD
//
//  Created by mac1 on 15/9/14.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCDealTool : NSObject

/**
 *  返回第page页的团购数据:page从1开始
 */
+ (NSArray *)collectDeals:(int)page;
+ (int)collectDealsCount;

/**
 *  最近团购数据
 */
//+ (NSArray *)recentDeals:(int)page;



/**
 *  收藏一个团购
 *
 *  @param deal
 */
+ (void)addCollect:(LCDeal *)deal;

//取消一个收藏
+ (void)removeCollect:(LCDeal *)deal;


//是否收藏
+ (BOOL)isCollect:(LCDeal *)deal;

// *  收藏一个团购
//+ (void)addCollect:(LCDeal *)deal;

@end
