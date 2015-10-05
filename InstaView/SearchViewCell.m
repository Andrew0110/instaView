//
//  SearchViewCell.m
//  InstaView
//
//  Created by Andrew on 16.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "SearchViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface SearchViewCell ()

@property (nonatomic) UIImageView *portraitImageView;
@property (nonatomic) UILabel     *label;
@property (nonatomic) UILabel     *detailedInfoLabel;


@end

@implementation SearchViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _portraitImageView             = [UIImageView new];
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_portraitImageView];
        
        _label = [UILabel new];
        _label.numberOfLines = 0;
        [self addSubview:_label];
        
        _detailedInfoLabel = [UILabel new];
        _detailedInfoLabel.numberOfLines = 0;
        _detailedInfoLabel.textColor = [UIColor grayColor];
        _detailedInfoLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_detailedInfoLabel];
    }
    
    return self;
}

- (void)configureWithUser:(InstaUser *)aUser {
    [_portraitImageView setImageWithURL:aUser.pictureProfile
                       placeholderImage:[UIImage imageNamed:@"placeholder"]];
    if (![aUser.fullName isEqual:@""] && aUser.fullName) {
        _label.text = [NSString stringWithFormat:@"%@(%@)", aUser.username, aUser.fullName];
    } else {
        _label.text = aUser.username;
    }
    if (aUser.mediaCount) {
        _detailedInfoLabel.text = [NSString stringWithFormat:@"Posts:%ld Followers:%ld", (long)aUser.mediaCount, (long)aUser.followersCount];
    } else {
        _detailedInfoLabel.text = @"Posts:0 Followers:0";
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat imageSize = self.bounds.size.height;
    
    _portraitImageView.frame = CGRectMake(5, 1, imageSize-2, imageSize-2);
    _label.frame = CGRectMake(imageSize+10, (imageSize-30)/2,
                              self.bounds.size.width - imageSize-10, 30);
    _detailedInfoLabel.frame = CGRectMake(imageSize+10, CGRectGetMaxY(_label.frame),
                                          self.bounds.size.width - imageSize-10, 10);
}

@end
