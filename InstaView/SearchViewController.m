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
#import "SortedImagesViewController.h"



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
    
    _searchView.searchBar.text = @"";

    _manager = [APIManager sharedManager];

    [self.searchView.tableView registerClass: [SearchViewCell class]
                      forCellReuseIdentifier: kSearchCellIdentifier];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem* logoutButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonClick)];
    [self.navigationItem setRightBarButtonItem:logoutButton];
    [self.navigationItem setHidesBackButton:NO];
    self.navigationItem.title = @"Search users";
    
//    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Actions

- (void)logoutButtonClick {
    APIManager* manager = [APIManager sharedManager];
    [manager logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RecentImagesViewController* recentViewController = [[RecentImagesViewController alloc] initWithUser:_users[indexPath.row]];
    SortedImagesViewController* sortedViewController = [[SortedImagesViewController alloc] initWithUser:_users[indexPath.row]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    recentViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Recent" image:nil tag:1];
    
    sortedViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Sorted" image:nil tag:2];
    
    tabBarController.viewControllers = [NSArray arrayWithObjects:
                                        recentViewController,
                                        sortedViewController,
                                        nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_searchView.searchBar resignFirstResponder];

    [self.navigationController pushViewController:tabBarController
                                         animated:YES];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [(SearchViewCell*)cell configureWithUser:self.users[indexPath.row]];
    if ( !((InstaUser*)self.users[indexPath.row]).mediaCount ) {
        __weak typeof(self) weakSelf = self;
        [_manager getUserInfoWithUser:self.users[indexPath.row] completion:^() {
            [(SearchViewCell*)cell configureWithUser:weakSelf.users[indexPath.row]];
//            [weakSelf.searchView.tableView reloadData];
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchCellIdentifier forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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
    [_manager searchUsersWithName:searchBar.text
                       completion:^(NSArray *users)
    {
        _users = users;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchView.tableView reloadData];
        });
    }];
    
    [searchBar resignFirstResponder];
}

@end
