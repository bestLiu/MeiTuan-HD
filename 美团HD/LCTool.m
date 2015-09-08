//
//  LCTool.m
//  美团HD
//
//  Created by mac1 on 15/9/8.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCTool.h"
#import "LCCity.h"
#import "LCCategory.h"
#import "MJExtension.h"
#import "LCSort.h"

@implementation LCTool

static NSArray *_cities;

+ (NSArray *)cities
{
    if (_cities == nil) {
        _cities = [LCCity objectArrayWithFilename:@"cities.plist"];
    }
    
    return _cities;
}

static NSArray *_categories;
+ (NSArray *)categories
{
    if (_categories == nil) {
        _categories = [LCCategory objectArrayWithFilename:@"categories.plist"];
    }
    return _categories;
}

static NSArray *_sorts;
+ (NSArray *)sorts
{
    if (_sorts == nil) {
        _sorts = [LCSort objectArrayWithFilename:@"sorts.plist"];
    }
    return _sorts;
}
@end
