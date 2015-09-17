//
//  InstagramPhotoViewCell.m
//  InstaView
//
//  Created by Andrew on 03.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "InstagramPhotoCell.h"

@implementation InstagramPhotoCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        _photoImgView = [[UIImageView alloc] init];
        _photoImgView.contentMode     = UIViewContentModeScaleAspectFit;
        [self addSubview:_photoImgView];

        
        _likesLabel = [UILabel new];
        _likesLabel.numberOfLines = 0;
        [self addSubview:_likesLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    int imageSize = [UIScreen mainScreen].bounds.size.width;
    
    _photoImgView.frame = CGRectMake(self.bounds.size.width/2 - imageSize/2,
                                0,
                                imageSize,
                                imageSize);
    _likesLabel.frame = CGRectMake(5,
                                    CGRectGetMaxY(_photoImgView.frame),
                                    _photoImgView.frame.size.width-5,
                                    30);
    [_likesLabel sizeToFit];
}


@end
