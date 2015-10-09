//
//  SelectViewController.m
//  InstaView
//
//  Created by Andrew on 07.10.15.
//  Copyright © 2015 obodev.com. All rights reserved.
//

#import "SelectViewController.h"
#import "SelectView.h"
#import "SearchViewController.h"
#import "RecommendFollowersViewController.h"
#import "RecentImagesViewController.h"
#import "APIManager.h"

@interface SelectViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) SelectView* selectView;
@property (nonatomic) NSArray* optionNames;

@end

@implementation SelectViewController

- (void) loadView {
    _selectView = [SelectView new];
    self.view = _selectView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _optionNames = @[@"My page", @"My stream", @"Search", @"Followers manager"];
    
    _selectView.tableView.dataSource = self;
    _selectView.tableView.delegate = self;
    
    _selectView.tableView.bounces = YES;
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem* logoutButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonClick)];
    [self.navigationItem setRightBarButtonItem:logoutButton];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = @"";

    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Actions

- (void)logoutButtonClick {
    APIManager* manager = [APIManager sharedManager];
    [manager logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController* viewController;
    
    if ( indexPath.row == 0 ) {
        viewController = [[RecentImagesViewController alloc] initWithUserID:[[APIManager sharedManager] currentUserID]];
    } else if ( indexPath.row == 1 ) {
        viewController = [UIViewController new];
    } else if ( indexPath.row == 2 ) {
        viewController = [SearchViewController new];
    } else if ( indexPath.row == 3 ) {
        viewController = [RecommendFollowersViewController new];
    }
    
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _optionNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _optionNames[indexPath.row];

    return cell;
}


@end
