//
//  ViewController.h
//  InstaView
//
//  Created by Andrew on 03.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InstaUser;

@interface RecentImagesViewController : UIViewController

- (instancetype)initWithUser:(InstaUser*) user;
- (instancetype)initWithUserID:(NSString*) userID;

@end

