//
//  SearchViewController.m
//  InstaView
//
//  Created by Andrew on 15.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RecentImagesViewController.h"
#import "APIManager.h"
#import "InstaUser.h"
#import "SearchViewCell.h"



@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic) SearchView* searchView;

@property (nonatomic) NSArray *users;
@property (nonatomic) APIManager *manager;

@end

@implementation SearchViewController

static NSString * const kSearchCellIdentifier = @"SearchViewControllerCell";
static NSUInteger const kCellHeight = 60;


- (void) loadView {
    _searchView = [SearchView new];
    self.view = _searchView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchView.tableView.dataSource = self;
    _searchView.tableView.delegate = self;
    _searchView.searchBar.delegate = self;
    
    _searchView.tableView.bounces = YES;
    _searchView.tableView.showsVerticalScrollIndicator = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _searchView.searchBar.text = @"Andrew";

    _manager = [APIManager sharedManager];

    [_manager searchUsersWithName:@"Andrew" completion:^(NSArray *users) {
        _users = users;
        
        [self.searchView.tableView reloadData];
    }];
    [self.searchView.tableView registerClass: [SearchViewCell class]
                      forCellReuseIdentifier: kSearchCellIdentifier];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RecentImagesViewController* viewController = [[RecentImagesViewController alloc] initWithUserId:((InstaUser*)_users[indexPath.row]).userID];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_searchView.searchBar resignFirstResponder];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [(SearchViewCell*)cell configureWithUser:self.users[indexPath.row]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchCellIdentifier forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchView.searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    _users = @[];
    [_searchView.tableView reloadData];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_manager searchUsersWithName:searchBar.text completion:^(NSArray *users) {
        _users = users;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchView.tableView reloadData];
        });
    }];
    
    [searchBar resignFirstResponder];
}


@end
