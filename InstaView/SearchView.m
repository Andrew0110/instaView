//
//  SearchView.m
//  InstaView
//
//  Created by Andrew on 15.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "SearchView.h"

@implementation SearchView

static CGFloat const kSearchBarHeight = 44;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _tableView = [UITableView new];
        [self addSubview:_tableView];
        
        
        _searchBar = [UISearchBar new];
        [self addSubview:_searchBar];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat width = self.bounds.size.width;
    const CGFloat height = self.bounds.size.height;
    
    CGFloat yOffset = 20;
    
    _searchBar.frame = CGRectMake(0, yOffset, width, kSearchBarHeight);
    yOffset += CGRectGetHeight(_searchBar.frame);
    _tableView.frame = CGRectMake(0, yOffset, width, height-yOffset);
}

@end
