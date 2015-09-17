//
//  SearchViewCell.m
//  InstaView
//
//  Created by Andrew on 16.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "SearchViewCell.h"

@implementation SearchViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.contentMode     = UIViewContentModeScaleAspectFit;
        [self addSubview:_portraitImageView];
        
        
        _label = [UILabel new];
        _label.numberOfLines = 0;
        //        _likesLabel.lineBreakMode = NSLineBreakByCharWrapping;
        //        _likesLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //static const
    int imageSize = self.bounds.size.height;
    
    _portraitImageView.frame = CGRectMake(5,
                                     1,
                                     imageSize-2,
                                     imageSize-2);
    _label.frame = CGRectMake(imageSize+10, (imageSize-30)/2,
                              self.bounds.size.width - imageSize-10, 30);
    
    
}
@end
