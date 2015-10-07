//
//  AppDelegate.m
//  InstaView
//
//  Created by Andrew on 03.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "AppDelegate.h"
#import "InstagramLoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: [InstagramLoginViewController new]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
