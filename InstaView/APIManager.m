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

@implementation APIManager {
    NSURL *baseURL;
    NSString *baseMethod;
    NSString *accessToken;
    long long unsigned int timestamp;
}

+ (APIManager *)sharedManager {
    static APIManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [APIManager new];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) setBaseURL:(NSURL *)url {
    baseURL = url;
}

- (void) setMethod:(NSString *)method {
    baseMethod = method;
}

- (void) setAccessToken:(NSString *)access {
    accessToken = access;
}

- (void) requestWithParams:(NSDictionary *)parameters completion:(void (^)(NSMutableArray*, NSURL*))completion {
    NSURL *url;
    NSMutableString *request = [NSMutableString stringWithFormat:@"%@%@?",[baseURL absoluteString], baseMethod];
    
    for ( NSString *key in parameters.allKeys ) {
        [request appendString:[NSString stringWithFormat:@"%@=%@&", key, [parameters objectForKey:key]]];
    }
    [request appendString:[NSString stringWithFormat:@"access_token=%@", accessToken]];
    NSLog(@"Request %@", request);
    url = [NSURL URLWithString:request];
    
    [self requestWithURL:url completion:completion];
}

- (void) searchForName:(NSString*)name withCompletion:(void (^)(NSArray *))completion {
    NSURLSessionConfiguration *config =[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:nil];
    NSMutableString *request = [NSMutableString stringWithFormat:@"%@users/search?q=%@&",[baseURL absoluteString], name];

    [request appendString:[NSString stringWithFormat:@"access_token=%@", accessToken]];
    NSLog(@"Search %@", request);
    NSURL *url = [NSURL URLWithString:request];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    
    [[session dataTaskWithRequest:req
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:0
                                                                                 error:nil];
                    //NSLog(@"%@", jsonObject);
                    NSMutableArray *instaUsers = [NSMutableArray array];
                    for ( NSDictionary *dict in [jsonObject objectForKey:@"data"] ) {
                        InstaUser *user = [InstaUser new];
                        user.username = dict[@"username"];
                        user.userID = dict[@"id"];
                        user.pictureProfile = [NSURL URLWithString:dict[@"profile_picture"]];
                        [instaUsers addObject:user];
                    }
                    completion(instaUsers);
                }
      ] resume];

    
    
}

- (void) requestWithURL:(NSURL *)url completion:(void (^)(NSMutableArray*, NSURL*))completion {
    NSURLSessionConfiguration *config =[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:nil];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [[session dataTaskWithRequest:req
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:0
                                                                                 error:nil];
                    //NSLog(@"%@", jsonObject);
                    NSURL* nextURL = [NSURL URLWithString:jsonObject[@"pagination"][@"next_url"]];
                    NSMutableArray* media = [NSMutableArray new];
                    
                    for ( NSDictionary *dict in [jsonObject objectForKey:@"data"]) {
                        if ([dict[@"type"] isEqualToString:@"image"]) {
                            MediaData* mediaData = [MediaData new];
                            mediaData.likes = [dict[@"likes"][@"count"] longLongValue];
                            mediaData.photoURL = [NSURL URLWithString: dict[@"images"][@"low_resolution"][@"url"]];
                            if ( dict[@"caption"] != [NSNull null] ) {
                                //NSLog(@"%@", dict[@"caption"][@"text"]);
                                mediaData.caption = dict[@"caption"][@"text"];
                                mediaData.username = dict[@"caption"][@"from"][@"username"];
                            }
                            
                            NSMutableArray* allComments = [NSMutableArray array];
                            NSMutableArray* users = [NSMutableArray array];
                            NSMutableArray* usersCommentedID = [NSMutableArray array];
                            
                            for ( NSDictionary *comment in dict[@"comments"][@"data"] ) {
                                [allComments addObject:comment[@"text"]];
                                [users addObject:comment[@"from"][@"username"]];
                                [usersCommentedID addObject:comment[@"from"][@"id"]];
                            }
                            
                            mediaData.comments = allComments;
                            mediaData.usersCommented = users;
                            mediaData.userCommentedIDs = usersCommentedID;
                            
                            [media addObject:mediaData];
                        }
                    }
                    completion(media, nextURL);
                }
      ] resume];
}


@end
