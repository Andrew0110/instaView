//
//  ViewController.h
//  InstaView
//
//  Created by Andrew on 03.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentImagesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype) initWithUserId:(NSString*) userID;

@end

