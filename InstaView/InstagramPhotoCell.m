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
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.scrollEnabled = NO;
        _textView.selectable    = NO;
        _textView.editable      = NO;
        [self addSubview:_textView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.height = frame.size.width;
    self.photoImgView.frame = frame;
    
    _textView.frame = CGRectMake(5,
                                CGRectGetMaxY(_photoImgView.frame),
                                CGRectGetWidth(self.photoImgView.frame)-10,
                                1);
    [_textView sizeToFit];
}


@end
