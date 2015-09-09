//
//  LCRecentViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/9.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCRecentViewController.h"

@interface LCRecentViewController ()

@end

@implementation LCRecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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


@end
