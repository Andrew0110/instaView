//
//  UserInfoCell.m
//  InstaView
//
//  Created by Andrew on 09.10.15.
//  Copyright © 2015 obodev.com. All rights reserved.
//

#import "UserInfoCell.h"
#import "InstaUser.h"
#import "UIImageView+AFNetworking.h"

@interface UserInfoCell()

@property (nonatomic) UIImageView *portraitImageView;
@property (nonatomic) UILabel     *label;
@property (nonatomic) UILabel     *websiteInfoLabel;
@property (nonatomic) UILabel     *detailedInfoLabel;

@end

@implementation UserInfoCell


- (instancetype)init
{
    self = [super init];
    if (self) {
        _portraitImageView             = [UIImageView new];
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_portraitImageView];
        
        _label = [UILabel new];
        _label.numberOfLines = 0;
        [self addSubview:_label];
        
        _websiteInfoLabel = [UILabel new];
        _websiteInfoLabel.numberOfLines = 0;
        _websiteInfoLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_websiteInfoLabel];
        
        _detailedInfoLabel = [UILabel new];
        _detailedInfoLabel.numberOfLines = 0;
//        _detailedInfoLabel.textColor = [UIColor grayColor];
        _detailedInfoLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_detailedInfoLabel];

    }
    return self;
}

- (void)configureWithUser:(InstaUser *)aUser {
    [_portraitImageView setImageWithURL:aUser.pictureProfile
                       placeholderImage:[UIImage imageNamed:@"placeholder"]];
    _label.text = [NSString stringWithFormat:@"%@(%@)", aUser.username, aUser.fullName];
    _websiteInfoLabel.text = [NSString stringWithFormat:@"Website: %@", [aUser.website absoluteString]];
    _detailedInfoLabel.text = [NSString stringWithFormat:@"Media:%ld\nFollowers:%ld\nFollows:%ld", (long)aUser.mediaCount, (long)aUser.followersCount, (long)aUser.followsCount];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat imageSize = self.bounds.size.height;
    
    _portraitImageView.frame = CGRectMake(5, 1, imageSize-10, imageSize-10);
    _label.frame = CGRectMake(imageSize+10, 20,
                              self.bounds.size.width - imageSize - 10, 30);
    _websiteInfoLabel.frame = CGRectMake(imageSize+10, CGRectGetMaxY(_label.frame),
                                          self.bounds.size.width - imageSize-10, 20);
    _detailedInfoLabel.frame = CGRectMake(imageSize+10, CGRectGetMaxY(_websiteInfoLabel.frame),
                                          self.bounds.size.width - imageSize-10, 80);
}

@end
