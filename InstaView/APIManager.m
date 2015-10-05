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

@property (nonatomic) NSString * requestMethod;

@end

@implementation APIManager

static NSString * const kBaseURL = @"https://api.instagram.com/v1/";
static NSString * const kAccessToken = @"2162679026.a5e3084.7892c75453b04d4bac276f8f7c08d461";

+ (APIManager *)sharedManager {
    static APIManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [APIManager new];
    });
    
    return manager;
}

- (void) getImagesWithParams:(NSDictionary *)parameters completion:(void (^)(NSMutableArray*, NSURL*))completion {
    NSURL *url;
    NSMutableString *request = [NSMutableString stringWithFormat:@"%@%@?",kBaseURL, _requestMethod];
    
    for ( NSString *key in parameters.allKeys ) {
        [request appendString:[NSString stringWithFormat:@"%@=%@&", key, [parameters objectForKey:key]]];
    }
    [request appendString:[NSString stringWithFormat:@"access_token=%@", kAccessToken]];

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
    [request appendString:[NSString stringWithFormat:@"access_token=%@", kAccessToken]];
    
    url = [NSURL URLWithString:request];
    
    [self getImagesWithURL:url completion:completion];
}

- (void) searchUsersWithName:(NSString*)name completion:(void (^)(NSArray *))completion {
    [[AFHTTPRequestOperationManager manager] GET: [NSString stringWithFormat:@"%@users/search/", kBaseURL]
                                      parameters:@{@"q":name,
                                                   @"access_token": kAccessToken}
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
                                      parameters:@{@"access_token": kAccessToken}
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
- (void) getAllImagesWithUserID:(NSString *)userID completion:(void (^)(NSMutableArray*))completion {
    NSMutableArray* loadedMedia = [NSMutableArray new];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"36", @"count", nil];
    
    __block void (^completionBlock)(NSMutableArray*, NSURL*) = ^(NSMutableArray* media, NSURL* nextURL){
        NSLog(@"Next url: %@ Count of media: %lu", nextURL, (unsigned long)media.count);
        if (nextURL) {
            [loadedMedia addObjectsFromArray:media];
            [self getImagesWithURL:nextURL
                        completion:completionBlock];
        } else {
            [loadedMedia addObjectsFromArray:media];
            completion(loadedMedia);
        }
    };
    if (completion) {
        [self getImagesWithUserID:userID
                           params:params
                       completion:completionBlock];
    }
    
}


@end
