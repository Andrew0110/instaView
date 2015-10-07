//
//  APIManager.m
//  InstaView
//
//  Created by Andrew on 05.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "APIManager.h"
#import "MediaData.h"
#import "InstaUser.h"
#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface APIManager()

@property (nonatomic) NSString * accessToken;

@end

@implementation APIManager

static NSString * const kBaseURL = @"https://api.instagram.com/v1/";
static NSString * const kAccessToken = @"2162679026.a5e3084.7892c75453b04d4bac276f8f7c08d461";
static NSString * const kClientID = @"a5e3084950fe4b978087777c1edd1098";
static NSString * const kClientSecret = @"4600695c7a6d46f38d4bef47df57c3f0";
static NSString * const kRedirectURI = @"http://localhost";


- (instancetype)init {
    self = [super init];
    if (self) {
//        _accessToken = kAccessToken;
    }
    
    return self;
}

+ (APIManager *)sharedManager {
    static APIManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [APIManager new];
    });
    
    return manager;
}

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
}

- (void)logout {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [[storage cookies] enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        [storage deleteCookie:cookie];
    }];
    
    self.accessToken = nil;
}

- (void) getImagesWithParams:(NSDictionary *)parameters completion:(void (^)(NSMutableArray*, NSURL*))completion {
    NSURL *url;
    NSMutableString *request = [NSMutableString stringWithFormat:@"%@media/recent/?",kBaseURL];
    
    for ( NSString *key in parameters.allKeys ) {
        [request appendString:[NSString stringWithFormat:@"%@=%@&", key, [parameters objectForKey:key]]];
    }
    [request appendString:[NSString stringWithFormat:@"access_token=%@", _accessToken]];

    url = [NSURL URLWithString:request];
    
    [self getImagesWithURL:url completion:completion];
}

- (void) getImagesWithUserID:(NSString *)userID
                      params:(NSDictionary *)parameters
                  completion:(void (^)(NSMutableArray*, NSURL*))completion {
    NSURL *url;
    NSMutableString *request = [NSMutableString stringWithFormat:@"%@users/%@/media/recent/?",kBaseURL, userID];
    
    for ( NSString *key in parameters.allKeys ) {
        [request appendString:[NSString stringWithFormat:@"%@=%@&", key, [parameters objectForKey:key]]];
    }
    [request appendString:[NSString stringWithFormat:@"access_token=%@", _accessToken]];
    
    url = [NSURL URLWithString:request];
    
    [self getImagesWithURL:url completion:completion];
}

- (void) searchUsersWithName:(NSString*)name completion:(void (^)(NSArray *))completion {
    [[AFHTTPRequestOperationManager manager] GET: [NSString stringWithFormat:@"%@users/search/", kBaseURL]
                                      parameters:@{@"q":name,
                                                   @"access_token": _accessToken}
                                         success:^(AFHTTPRequestOperation * operation, id response) {
                                             if ([response isKindOfClass: [NSDictionary class]]) {
                                                 NSMutableArray *instaUsers = [NSMutableArray array];
                                                 for ( NSDictionary *dict in response[@"data"] ) {
                                                     [instaUsers addObject:[InstaUser instaUserFromDict:dict]];
                                                 }
                                                 if (completion) {
                                                     completion(instaUsers);
                                                 }
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"%@", error);
                                         }];
}

- (void) getImagesWithURL:(NSURL *)url completion:(void (^)(NSMutableArray*, NSURL*))completion {
    NSLog(@"%@", url);
    [[AFHTTPRequestOperationManager manager] GET:[url absoluteString]
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation * operation, id response) {
                                            if ([response isKindOfClass: [NSDictionary class]]) {
                                                NSURL* nextURL = [NSURL URLWithString:response[@"pagination"][@"next_url"]];
                                                NSMutableArray* media = [NSMutableArray new];
                                                
                                                for ( NSDictionary *dict in response[@"data"] ) {
                                                    if ([dict[@"type"] isEqualToString:@"image"]) {
                                                        [media addObject:[MediaData mediaDataFromDict:dict]];
                                                    }
                                                }
                                                if (completion) {
                                                    completion(media, nextURL);
                                                }
                                            }
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            UIAlertView *alertView = [[UIAlertView alloc]
                                                                      initWithTitle:@"Error"
                                                                      message:@"Sorry. You can't look this account"
                                                                      delegate:nil
                                                                      cancelButtonTitle:@"Ok"
                                                                      otherButtonTitles:nil];
                                            
                                            [alertView show];
                                        }];
}

- (void)getUserInfoWithUser:(InstaUser *)user
               completion:(void (^)(void))completion {
    [[AFHTTPRequestOperationManager manager] GET:[NSString stringWithFormat:@"%@users/%@/", kBaseURL, user.userID]
                                      parameters:@{@"access_token": _accessToken}
                                         success:^(AFHTTPRequestOperation * operation, id response) {
                                             if ([response isKindOfClass: [NSDictionary class]]) {
                                                 [user loadDetailsFromDict:response[@"data"]];
                                                 if (completion) {
                                                     completion();
                                                 }
                                             }
                                         }
                                         failure:nil];

}


// How to stop completion block, when ViewController release?
//- (void) getAllImagesWithUserID:(NSString *)userID completion:(void (^)(NSMutableArray*))completion {
//    NSMutableArray* loadedMedia = [NSMutableArray new];
//    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"36", @"count", nil];
//    
//    __block void (^completionBlock)(NSMutableArray*, NSURL*) = ^(NSMutableArray* media, NSURL* nextURL){
//        NSLog(@"Next url: %@ Count of media: %lu", nextURL, (unsigned long)media.count);
//        if (nextURL) {
//            [loadedMedia addObjectsFromArray:media];
//            [self getImagesWithURL:nextURL
//                        completion:completionBlock];
//        } else {
//            [loadedMedia addObjectsFromArray:media];
//            completion(loadedMedia);
//        }
//    };
//    if (completion) {
//        [self getImagesWithUserID:userID
//                           params:params
//                       completion:completionBlock];
//    }
//    
//}


@end
