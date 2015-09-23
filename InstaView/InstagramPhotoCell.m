//
//  InstagramPhotoViewCell.m
//  InstaView
//
//  Created by Andrew on 03.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "InstagramPhotoCell.h"

@implementation InstagramPhotoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _photoImgView = [[UIImageView alloc] init];
        _photoImgView.contentMode     = UIViewContentModeScaleAspectFit;
        [self addSubview:_photoImgView];
        
        _textView = [UITextView new];
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        [self addSubview:_textView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    const int imageSize = [UIScreen mainScreen].bounds.size.width;
    
    _photoImgView.frame = CGRectMake(0,
                                     0,
                                     imageSize,
                                     imageSize);
    
    _textView.frame = CGRectMake(5,
                                CGRectGetMaxY(_photoImgView.frame),
                                imageSize-10,
                                1);
    [_textView sizeToFit];
    
}


@end
