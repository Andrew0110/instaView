//
//  InstagramLoginViewController.m
//  InstaView
//
//  Created by Andrew on 06.10.15.
//  Copyright © 2015 obodev.com. All rights reserved.
//

#import "InstagramLoginViewController.h"
#import "SearchViewController.h"
#import "APIManager.h"

@interface InstagramLoginViewController ()<UIWebViewDelegate>{
    NSString *client_id;
    NSString *secret;
    NSString *callback;
    NSMutableData *receivedData;
    
}

@property (nonatomic) UIWebView* webView;
@property (nonatomic, retain) NSString *isLogin;


@end

@implementation InstagramLoginViewController

- (void) loadView {
    _webView = [UIWebView new];
    self.view = _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    client_id = @"a5e3084950fe4b978087777c1edd1098";
    secret = @"4600695c7a6d46f38d4bef47df57c3f0";
    callback = @"http://localhost";
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code", client_id, callback];
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {

    if ([[[request URL] host] isEqualToString:@"localhost"]) {
        
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
        }
        
        if (verifier) {
            
            NSString *data = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",client_id,secret,callback,verifier];
            
            NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/oauth/access_token"];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            [theConnection start];
            receivedData = [[NSMutableData alloc] init];
        } else {
            NSLog(@"err");
        }
        
        return NO;
    } else {
        
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"%@", error]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData
                                                               options:0
                                                                 error:nil];
    
    APIManager* manager = [APIManager sharedManager];
    [manager setAccessToken:[jsonObject objectForKey:@"access_token"]];

    [self.navigationController pushViewController:[SearchViewController new] animated:YES];
}

@end
