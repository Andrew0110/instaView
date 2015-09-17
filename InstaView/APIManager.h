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

- (void) setBaseURL:(NSURL *)url;
- (void) setMethod:(NSString *)method;
- (void) setAccessToken:(NSString *)access;
- (void) requestWithParams:(NSDictionary *)parameters completion:(void (^)(NSMutableArray *, NSURL*))completion;
- (void) searchForName:(NSString*)name withCompletion:(void (^)(NSArray *))completion;
- (void) requestWithURL:(NSURL *)url completion:(void (^)(NSMutableArray *, NSURL *))completion;

@end
