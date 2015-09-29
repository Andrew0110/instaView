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

@end
