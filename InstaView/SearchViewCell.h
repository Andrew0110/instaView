//
//  SearchViewCell.h
//  InstaView
//
//  Created by Andrew on 16.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstaUser.h"

@interface SearchViewCell : UITableViewCell

- (void)configureWithUser:(InstaUser *)aUser;

@end
