//
//  Profile.m
//  InstaView
//
//  Created by Andrew on 07.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "MediaData.h"

@implementation MediaData

@synthesize attributedText = _attributedText;

- (NSAttributedString *)attributedText {
    if (!_attributedText) {
        NSMutableArray *usernameRanges = [NSMutableArray array];
        
        NSMutableString *text = [NSMutableString stringWithFormat:@"likes: %ld", _likes];
        NSRange likesRange = NSMakeRange(0, 6);
        NSRange commentsCountRange = NSMakeRange(text.length+1, 8);
        [text appendFormat:@"\nComments: %ld\n", (long)_commentsCount];
        
        NSRange boldedRange = NSMakeRange(text.length+1, _username.length);
        if (_username) {
            [text appendFormat:@"\n%@: %@\n", _username, _caption];
        } else {
            [text appendString:@"\n"];
        }
        
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
        
        NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05
                                                                                           green:0.4
                                                                                            blue:0.65
                                                                                           alpha:1.0],
                                          NSFontAttributeName : [UIFont boldSystemFontOfSize:14]};
        [attributedText setAttributes:linkAttributes range:commentsCountRange];
        [attributedText setAttributes:linkAttributes range:boldedRange];
        [attributedText setAttributes:linkAttributes range:likesRange];
        
        for ( int i = 0; i < usernameRanges.count; i++ ) {
            [attributedText setAttributes:linkAttributes range:((NSValue*)usernameRanges[i]).rangeValue];
        }
        _ranges = usernameRanges;
        _attributedText = attributedText;
    }
    return _attributedText;
}

+ (MediaData *)mediaDataFromDict:(NSDictionary *)source {
    MediaData *mediaData = [MediaData new];
    
    mediaData.likes = [source[@"likes"][@"count"] longLongValue];
    mediaData.photoURL = [NSURL URLWithString: source[@"images"][@"low_resolution"][@"url"]];
    if ( source[@"caption"] != [NSNull null] ) {
        mediaData.caption = source[@"caption"][@"text"];
        mediaData.username = source[@"caption"][@"from"][@"username"];
    }
    
    mediaData.commentsCount = [source[@"comments"][@"count"] longLongValue];
    
    NSMutableArray* allComments = [NSMutableArray array];
    NSMutableArray* users = [NSMutableArray array];
    NSMutableArray* usersCommentedID = [NSMutableArray array];
    
    for ( NSDictionary *comment in source[@"comments"][@"data"] ) {
        [allComments addObject:comment[@"text"]];
        [users addObject:comment[@"from"][@"username"]];
        [usersCommentedID addObject:comment[@"from"][@"id"]];
    }
    
    mediaData.comments = allComments;
    mediaData.usersCommented = users;
    mediaData.userCommentedIDs = usersCommentedID;
    
    return mediaData;
}

@end
