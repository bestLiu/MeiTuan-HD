//
//  LCHomeDropView.m
//  美团HD
//
//  Created by mac1 on 15/9/7.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//


#import "LCHomeDropView.h"
#import "LCCategory.h"
#import "LCHomeDropMainTableViewCell.h"
#import "LCHomeDropSubTableViewCell.h"

@interface LCHomeDropView ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UITableView *followTableViw;

@property (nonatomic, strong) LCCategory *selectedCategory;

@end


@implementation LCHomeDropView

+ (instancetype)dropView
{
    return [[NSBundle mainBundle] loadNibNamed:@"LCHomeDropView" owner:nil options:nil][0];
}

- (void)awakeFromNib
{
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}

#pragma mark 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.mainTableView) {
        return self.categroies.count;
    }
    else{
        return self.selectedCategory.subcategories.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (tableView == self.mainTableView)
    {
        cell = [LCHomeDropMainTableViewCell cellWithTableViw:tableView];
        
        LCCategory *category = self.categroies[indexPath.row];
        //显示文字
        cell.textLabel.text = category.name;
        cell.imageView.image = [UIImage imageNamed:category.small_icon];
       
        if (category.subcategories.count) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

    }
    else
    {
        cell = [LCHomeDropSubTableViewCell cellWithTableViw:tableView];
        cell.textLabel.text = self.selectedCategory.subcategories[indexPath.row];
    }
    
    
    return cell;
}

#pragma mark -表的代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.mainTableView) {
        self.selectedCategory = self.categroies[indexPath.row];
        [self.followTableViw reloadData];

    }
}

@end
