//
//  RootView.m
//  InstaView
//
//  Created by Andrew on 03.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "RecentImagesView.h"

@implementation RecentImagesView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _tableView = [UITableView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    _tableView.frame = self.bounds;
}

@end
