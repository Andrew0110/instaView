//
//  Profile.m
//  InstaView
//
//  Created by Andrew on 07.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "MediaData.h"

@implementation MediaData

- (NSAttributedString*) getAttributedText {
    NSMutableArray *usernameRanges = [NSMutableArray array];
    
    NSMutableString *text = [NSMutableString stringWithFormat:@"likes: %ld", _likes];
    NSRange likesRange = NSMakeRange(0, 6);
    
    NSRange boldedRange = NSMakeRange(text.length+1, _username.length);
    [text appendFormat:@"\n%@: %@\n", _username, _caption];

    
    for ( int i = 0; i < _comments.count; i++ ) {
        NSRange linkedRange = NSMakeRange(text.length+1, ((NSString*)_usersCommented[i]).length);
        [text appendFormat:@"\n%@ %@", _usersCommented[i], _comments[i]];
        [usernameRanges addObject:[NSValue valueWithRange:linkedRange]];
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    
    [attributedText beginEditing];
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont systemFontOfSize:14]
                           range: NSMakeRange(0, attributedText.length)];
    [attributedText endEditing];
    
    NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                      NSFontAttributeName : [UIFont boldSystemFontOfSize:14]};
    [attributedText setAttributes:linkAttributes range:boldedRange];
    [attributedText setAttributes:linkAttributes range:likesRange];


    
    for ( int i = 0; i < usernameRanges.count; i++ ) {
        [attributedText setAttributes:linkAttributes range:((NSValue*)usernameRanges[i]).rangeValue];
    }
    _ranges = usernameRanges;

    return attributedText;
}

@end
