//
//  RecommendFollowersView.m
//  InstaView
//
//  Created by Andrew on 08.10.15.
//  Copyright © 2015 obodev.com. All rights reserved.
//

#import "RecommendFollowersView.h"

@implementation RecommendFollowersView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        [self addSubview:_tableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _tableView.frame = self.bounds;
}

@end
