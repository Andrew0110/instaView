//
//  RootView.m
//  InstaView
//
//  Created by Andrew on 03.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "RootView.h"

@implementation RootView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _tableView = [UITableView new];
        [self addSubview:_tableView];
    }
    return self;
}

- (void) layoutSubviews {
    _tableView.frame = self.bounds;
}

@end
