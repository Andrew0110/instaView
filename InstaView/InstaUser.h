//
//  InstaUser.h
//  InstaView
//
//  Created by Andrew on 15.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstaUser : NSObject

@property (nonatomic) NSString  *username;
@property (nonatomic) NSString  *fullName;
@property (nonatomic) NSString  *userID;
@property (nonatomic) NSURL     *pictureProfile;
@property (nonatomic) NSInteger mediaCount;
@property (nonatomic) NSInteger followersCount;
@property (nonatomic) NSInteger followsCount;
@property (nonatomic) float indexOfFollowing;

+ (InstaUser *)instaUserFromDict:(NSDictionary *)source;

- (void)loadDetailsFromDict:(NSDictionary *)source;

@end
