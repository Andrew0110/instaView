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

- (void) setMethod:(NSString*)method {
    _requestMethod = [NSString stringWithString: method];
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
    [[AFHTTPRequestOperationManager manager] GET:[url absoluteString]
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation * operation, id response) {
                                            if ([response isKindOfClass: [NSDictionary class]]) {
                                                NSURL* nextURL = [NSURL URLWithString:response[@"pagination"][@"next_url"]];
                                                NSMutableArray* media = [NSMutableArray new];
                                                
                                                for ( NSDictionary *dict in response[@"data"]) {
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


@end
