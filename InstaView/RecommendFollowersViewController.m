//
//  RecommendFollowersViewController.m
//  InstaView
//
//  Created by Andrew on 08.10.15.
//  Copyright © 2015 obodev.com. All rights reserved.
//

#import "RecommendFollowersViewController.h"
#import "RecommendFollowersView.h"
#import "APIManager.h"
#import "InstaUser.h"
#import "SearchViewCell.h"

@interface RecommendFollowersViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) RecommendFollowersView* recommendFollowersView;
@property (nonatomic) APIManager* manager;
@property (nonatomic) NSMutableDictionary* followers;
@property (nonatomic) NSMutableDictionary* follows;
@property (nonatomic) NSMutableArray* recommendFollowList;
@property (nonatomic) NSMutableArray* recommendUnfollowList;
@property (nonatomic) NSURL* nextFollowersURL;
@property (nonatomic) NSURL* nextFollowsURL;
@property (nonatomic) BOOL isFollowsLoaded;
@property (nonatomic) BOOL isFollowersLoaded;

@end

@implementation RecommendFollowersViewController

static NSString * const kRecommendFollowerIdentifier = @"RecommendFollowerCell";
static NSUInteger const kCellHeight = 60;

- (void)loadView {
    _recommendFollowersView = [RecommendFollowersView new];
    self.view = _recommendFollowersView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recommendFollowersView.tableView.dataSource = self;
    _recommendFollowersView.tableView.delegate = self;
    
    _recommendFollowersView.tableView.bounces = YES;
    _recommendFollowersView.tableView.showsVerticalScrollIndicator = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _followers = [NSMutableDictionary dictionary];
    _follows = [NSMutableDictionary dictionary];
    _recommendFollowList = [NSMutableArray array];
    _recommendUnfollowList = [NSMutableArray array];
    
    _manager = [APIManager sharedManager];
    
    [self getAllFollowers];
    [self getAllFollows];
    
    [self.recommendFollowersView.tableView registerClass: [SearchViewCell class]
                      forCellReuseIdentifier: kRecommendFollowerIdentifier];
    
}

#pragma mark - API actions

- (void) getAllFollowers {
    __weak typeof(self) weakSelf = self;
    
    __block void (^completionBlock)(NSMutableArray*, NSURL*) = ^(NSMutableArray* users, NSURL* nextURL){
        //NSLog(@"Next url: %@ Count of users: %lu", nextURL, (unsigned long)users.count);
        if (nextURL) {
            for ( InstaUser* user in users ) {
                [weakSelf.followers setValue:user forKey:user.userID];
            }
            weakSelf.nextFollowersURL = nextURL;
            [weakSelf getAllFollowers];
        } else {
            for ( InstaUser* user in users ) {
                [weakSelf.followers setValue:user forKey:user.userID];
            }
            weakSelf.isFollowersLoaded = YES;
            
            if ( weakSelf.isFollowsLoaded ) {
                [weakSelf findFollowRecommendList];
                [weakSelf findUnfollowRecommendList];
            }
        }
    };
    if (!_nextFollowersURL) {
        [_manager getFollowersWithCompletion:completionBlock];
    } else {
        [_manager getUsersWithURL:_nextFollowersURL completion:completionBlock];
    }
}

- (void) getAllFollows {
    __weak typeof(self) weakSelf = self;
    
    __block void (^completionBlock)(NSMutableArray*, NSURL*) = ^(NSMutableArray* users, NSURL* nextURL){
        //NSLog(@"Next url: %@ Count of users: %lu", nextURL, (unsigned long)users.count);
        if (nextURL) {
            for ( InstaUser* user in users ) {
                [weakSelf.follows setValue:user forKey:user.userID];
            }
            weakSelf.nextFollowsURL = nextURL;
            [weakSelf getAllFollows];
        } else {
            for ( InstaUser* user in users ) {
                [weakSelf.followers setValue:user forKey:user.userID];
            }
            
            weakSelf.isFollowsLoaded = YES;
            
            if ( weakSelf.isFollowersLoaded ) {
                [weakSelf findFollowRecommendList];
                [weakSelf findUnfollowRecommendList];
            }
        }
    };
    if (!_nextFollowsURL) {
        [_manager getFollowersWithCompletion:completionBlock];
    } else {
        [_manager getUsersWithURL:_nextFollowsURL completion:completionBlock];
    }
}

#pragma mark - FollowersActions

- (void)findUnfollowRecommendList {
    for ( NSString* userID in [self.follows allKeys] ) {
        if ( ![[self.followers allKeys] containsObject:userID] ) {
            [self.recommendUnfollowList addObject:[self.followers objectForKey:userID]];
        }
    }
    
//    NSLog(@"unfollowlist - %lu", (unsigned long)_recommendUnfollowList.count);
    
    [self.recommendFollowersView.tableView reloadData];
}

- (void)findFollowRecommendList {
    NSMutableString* followers = [NSMutableString new];
    for ( InstaUser* user in [self.followers allValues] ) {
        [followers appendFormat:@"%@ ", user.username];
    }
    NSMutableString* follows = [NSMutableString new];
    for ( InstaUser* user in [self.follows allValues] ) {
        [follows appendFormat:@"%@ ", user.username];
    }
    NSLog(@"Followers (%lu): %@", (unsigned long)_followers.count, followers);
    NSLog(@"Follows (%lu): %@", (unsigned long)_follows.count, follows);

    
    for ( NSString* userID in [self.followers allKeys] ) {
        if ( ![[self.follows allKeys] containsObject:userID] ) {
            [self.recommendFollowList addObject:[self.followers objectForKey:userID]];
//            NSLog(@"%@", ((InstaUser*)[self.followers objectForKey:userID]).username);
        }
    }
//    NSLog(@"followlist - %lu", (unsigned long)_recommendFollowList.count);

    
    [self.recommendFollowersView.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    InstaUser* user = (InstaUser*)self.recommendFollowList[indexPath.row];
    [(SearchViewCell*)cell configureWithUser:user];
    if ( !user.mediaCount ) {
        __weak typeof(self) weakSelf = self;
        [_manager getUserInfoWithUser:user completion:^() {
            [(SearchViewCell*)cell configureWithUser:weakSelf.recommendFollowList[indexPath.row]];
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _recommendFollowList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRecommendFollowerIdentifier forIndexPath:indexPath];
    
    return cell;
}

@end
