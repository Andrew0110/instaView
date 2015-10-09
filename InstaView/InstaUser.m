//
//  InstaUser.m
//  InstaView
//
//  Created by Andrew on 15.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "InstaUser.h"

@implementation InstaUser

+ (InstaUser *)instaUserFromDict:(NSDictionary *)source {
    InstaUser *user = [InstaUser new];
    
    user.username = source[@"username"];
    user.userID = source[@"id"];
    user.pictureProfile = [NSURL URLWithString:source[@"profile_picture"]];
    
    return user;
}

- (void)loadDetailsFromDict:(NSDictionary *)source {
    _userID = source[@"id"];
    _username = source[@"username"];
    _fullName = source[@"full_name"];
    _pictureProfile = [NSURL URLWithString:source[@"profile_picture"]];
    _mediaCount = [source[@"counts"][@"media"] longLongValue];
    _followersCount = [source[@"counts"][@"followed_by"] longLongValue];
    _followsCount = [source[@"counts"][@"follows"] longLongValue];
    _biography = source[@"bio"];
    _website = [NSURL URLWithString:source[@"website"]];
    if (_followsCount && _followsCount > 0) {
        _indexOfFollowing = _followersCount/_followsCount;
    } else {
        _indexOfFollowing = 0;
    }
}

@end
