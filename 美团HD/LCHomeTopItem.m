//
//  LCHomeTopItem.m
//  美团HD
//
//  Created by mac1 on 15/9/7.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//


#import "LCHomeTopItem.h"
@interface LCHomeTopItem ()

@property (weak, nonatomic) IBOutlet UIButton *iconButton;

@end

@implementation LCHomeTopItem

+ (instancetype)item
{
    return [[[NSBundle mainBundle] loadNibNamed:@"LCHomeTopItem" owner:nil options:nil] firstObject];
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.iconButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)awakeFromNib
{
    self.autoresizingMask = UIViewAutoresizingNone;
}

@end
