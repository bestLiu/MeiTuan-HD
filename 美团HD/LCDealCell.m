//
//  LCDealCell.m
//  美团HD
//
//  Created by apple on 14-8-19.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "LCDealCell.h"
#import "UIImageView+WebCache.h"

@interface LCDealCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *listPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UILabel *purchaseCountLabel;
/**
 属性名不能以new开头
 */
@property (weak, nonatomic) IBOutlet UIButton *coverButton;
@property (weak, nonatomic) IBOutlet UIImageView *dealNewView; 
@end

@implementation LCDealCell

- (void)awakeFromNib
{
    // 拉伸
//    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_dealcell"]];
    // 平铺
    //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_dealcell"]];
    self.checkImageView.hidden = YES;
}

- (void)setDeal:(LCDeal *)deal
{
    _deal = deal;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:deal.s_image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    self.titleLabel.text = deal.title;
    self.descLabel.text = deal.desc;
    
    // 购买数
    self.purchaseCountLabel.text = [NSString stringWithFormat:@"已售%d", deal.purchase_count];
    
    // 现价
    self.currentPriceLabel.text = [NSString stringWithFormat:@"¥ %@", deal.current_price];
    NSUInteger dotLoc = [self.currentPriceLabel.text rangeOfString:@"."].location;
    if (dotLoc != NSNotFound) {
        // 超过2位小数
        if (self.currentPriceLabel.text.length - dotLoc > 3) {
            self.currentPriceLabel.text = [self.currentPriceLabel.text substringToIndex:dotLoc + 3];
        }
    }
    
    // 原价
    self.listPriceLabel.text = [NSString stringWithFormat:@"¥ %@", deal.list_price];
    
    //是否显示新单图片
    //deal.publish_date == 2015-09-09
    NSDate *now = [NSDate date];
    NSDateFormatter *fomatter = [[NSDateFormatter alloc] init];
    fomatter.dateFormat = @"yyyy-MM-dd";
    NSString *nowStr = [fomatter stringFromDate:now];
    self.dealNewView.hidden = ([deal.publish_date compare:nowStr] == NSOrderedAscending);//比今天小就隐藏
    
    
    //根据模型属性来控制cover的显示和隐藏
    self.coverButton.hidden = !deal.editing;
    
    //根据模型属性控制打钩的显示与否
    self.checkImageView.hidden = !deal.ischecking;
}


- (IBAction)coverViewClick:(id)sender
{
    //设置模型
    self.deal.checking = !self.deal.ischecking;
    
    //修改状态
    self.checkImageView.hidden = !self.checkImageView.hidden;
    
    if ([self.delegate respondsToSelector:@selector(dealCellCheckingStateDidChange:)]) {
        [self.delegate dealCellCheckingStateDidChange:self];
    }
}


- (void)drawRect:(CGRect)rect
{
    // 平铺
//    [[UIImage imageNamed:@"bg_dealcell"] drawAsPatternInRect:rect];
    // 拉伸
    [[UIImage imageNamed:@"bg_dealcell"] drawInRect:rect];
}
@end
