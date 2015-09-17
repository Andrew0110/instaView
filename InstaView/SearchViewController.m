//
//  SearchViewController.m
//  InstaView
//
//  Created by Andrew on 15.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ViewController.h"
#import "APIManager.h"
#import "InstaUser.h"
#import "SearchViewCell.h"



@interface SearchViewController ()

@property (nonatomic) NSArray *users;
@property (nonatomic) APIManager *manager;

@end

@implementation SearchViewController

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
    [_manager setBaseURL:[NSURL URLWithString:@"https://api.instagram.com/v1/"]];
    [_manager setAccessToken:@"2162679026.a5e3084.7892c75453b04d4bac276f8f7c08d461"];

    [_manager searchForName:@"Andrew" withCompletion:^(NSArray *users) {
        _users = users;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchView.tableView reloadData];
        });
        
        //NSLog(@"%@, %ld", mediaData.photoURL, (long)mediaData.likes);
    }];
    

//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage: [[UIImage imageNamed:@"navbarBackBtn"]
//                                                                 resizableImageWithCapInsets:UIEdgeInsetsZero
//                                                                 resizingMode:UIImageResizingModeStretch]
//                                                      forState:UIControlStateNormal
//                                                    barMetrics:UIBarMetricsDefault];

    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewController* viewController = [[ViewController alloc] initWithUserId:((InstaUser*)_users[indexPath.row]).userID];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_searchView.searchBar resignFirstResponder];
    
    [self.navigationController pushViewController:viewController animated:YES];

}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"Cell";
    SearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    
    if (!cell) {
        cell = [SearchViewCell new];
    }
    
    [cell.portraitImageView setImageWithURL:((InstaUser*)_users[indexPath.row]).pictureProfile placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [cell.portraitImageView clipsToBounds];
    
    cell.label.text = ((InstaUser*)_users[indexPath.row]).username;

    return cell;
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar becomeFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchView.searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    _users = @[];
    [_searchView.tableView reloadData];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_manager searchForName:searchBar.text withCompletion:^(NSArray *users) {
        _users = users;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchView.tableView reloadData];
        });
    }];
    
    [searchBar resignFirstResponder];
}


@end
