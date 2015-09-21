//
//  APIManager.h
//  InstaView
//
//  Created by Andrew on 05.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MediaData;

@interface APIManager : NSObject

+ (APIManager *)sharedManager;

- (void) setMethod:(NSString*)method;
- (void) getImagesWithParams:(NSDictionary *)parameters completion:(void (^)(NSMutableArray *, NSURL*))completion;
- (void) searchUsersWithName:(NSString*)name completion:(void (^)(NSArray *))completion;
- (void) getImagesWithURL:(NSURL *)url completion:(void (^)(NSMutableArray *, NSURL *))completion;

@end
