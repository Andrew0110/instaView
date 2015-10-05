//
//  Profile.h
//  InstaView
//
//  Created by Andrew on 07.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MediaData : NSObject

@property (nonatomic) NSString      *mediaID;
@property (nonatomic) NSString      *username;
@property (nonatomic) NSString      *caption;
@property (nonatomic) NSURL         *photoURL;
@property (nonatomic) NSInteger     likes;
@property (nonatomic) NSArray       *comments;
@property (nonatomic) NSArray       *usersCommented;
@property (nonatomic) NSArray       *userCommentedIDs;
@property (nonatomic) NSArray       *ranges;
@property (nonatomic) NSInteger     commentsCount;

@property (nonatomic, strong, readonly) NSAttributedString *attributedText;

+ (MediaData *)mediaDataFromDict:(NSDictionary *)source;

@end
