//
//  UserInfoCell.h
//  InstaView
//
//  Created by Andrew on 09.10.15.
//  Copyright © 2015 obodev.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InstaUser;

@interface UserInfoCell : UITableViewCell

- (void)configureWithUser:(InstaUser *)aUser;

@end
