//
//  LCDealCell.h
//  美团HD

//
//  Created by apple on 14-8-19.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LCDealCell;

@protocol LCDealCellDelegate <NSObject>

@optional
- (void)dealCellCheckingStateDidChange:(LCDealCell *)cell;

@end

@interface LCDealCell : UICollectionViewCell
@property (nonatomic, strong) LCDeal *deal;
@property (nonatomic, weak) id<LCDealCellDelegate> delegate;

@end
