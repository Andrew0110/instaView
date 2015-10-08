//
//  SelectViewController.m
//  InstaView
//
//  Created by Andrew on 07.10.15.
//  Copyright © 2015 obodev.com. All rights reserved.
//

#import "SelectViewController.h"
#import "SearchViewController.h"
#import "RecommendFollowersViewController.h"
#import "SelectView.h"
#import "APIManager.h"

@interface SelectViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) SelectView* selectView;

@end

@implementation SelectViewController

- (void) loadView {
    _selectView = [SelectView new];
    self.view = _selectView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _selectView.tableView.dataSource = self;
    _selectView.tableView.delegate = self;
    
    _selectView.tableView.bounces = YES;
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        viewController = [SearchViewController new];
    } else if ( indexPath.row == 1 ) {
        viewController = [RecommendFollowersViewController new];
    }
    
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    if ( indexPath.row == 0 ) {
        cell.textLabel.text = @"Search";
    } else if ( indexPath.row == 1 ) {
        cell.textLabel.text = @"Followers";
    }
    
    return cell;
}


@end
