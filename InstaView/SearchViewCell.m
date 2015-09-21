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
    }
    
    return self;
}

- (void)configureWithUser:(InstaUser *)aUser {
    [_portraitImageView setImageWithURL:aUser.pictureProfile placeholderImage:[UIImage imageNamed:@"placeholder"]];
    _label.text = aUser.username;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const int imageSize = self.bounds.size.height;
    
    _portraitImageView.frame = CGRectMake(5, 1, imageSize-2, imageSize-2);
    _label.frame = CGRectMake(imageSize+10, (imageSize-30)/2,
                              self.bounds.size.width - imageSize-10, 30);
}
@end
