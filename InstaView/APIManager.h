//
//  APIManager.h
//  InstaView
//
//  Created by Andrew on 05.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MediaData;
@class InstaUser;

@interface APIManager : NSObject

@property (nonatomic) NSString* currentUserID;

+ (APIManager *)sharedManager;

- (void)setAccessToken:(NSString *)accessToken;
- (void)setCurrentUserID:(NSString*)userID;

- (void)getImagesWithParams:(NSDictionary *)parameters completion:(void (^)(NSMutableArray *, NSURL*))completion;
- (void)getImagesWithURL:(NSURL *)url completion:(void (^)(NSMutableArray *, NSURL *))completion;
- (void)getImagesWithUserID:(NSString *)userID
                      params:(NSDictionary *)parameters
                  completion:(void (^)(NSMutableArray*, NSURL*))completion;

- (void)searchUsersWithName:(NSString*)name completion:(void (^)(NSArray *))completion;
- (void)getUserInfoWithUser:(InstaUser *)user
               completion:(void (^)(void))completion;
- (void)getFollowersWithCompletion:(void (^)(NSMutableArray*, NSURL*))completion;
- (void)getFollowsWithCompletion:(void (^)(NSMutableArray*, NSURL*))completion;

- (void)getUsersWithURL:(NSURL *)url
             completion:(void (^)(NSMutableArray*, NSURL*))completion;

- (void)logout;

//- (void) getAllImagesWithUserID:(NSString *)userID completion:(void (^)(NSMutableArray*))completion;

@end
