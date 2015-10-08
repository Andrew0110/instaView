//
//  SortedImagesViewController.m
//  InstaView
//
//  Created by Andrew on 03.10.15.
//  Copyright © 2015 obodev.com. All rights reserved.
//

#import "SortedImagesViewController.h"
#import "APIManager.h"
#import "RecentImagesView.h"
#import "InstagramPhotoCell.h"
#import "MediaData.h"
#import "InstaUser.h"
#import "UIImageView+AFNetworking.h"

@interface SortedImagesViewController () <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>

@property (nonatomic) RecentImagesView* rootView;
@property (nonatomic) APIManager* manager;
@property (nonatomic) NSMutableArray* loadedData;
@property (nonatomic) NSString* instagramUserID;
@property (nonatomic) NSString* instagramUsername;
@property (nonatomic) NSURL* nextURL;
@property (nonatomic) NSString* sortBy;
@property (nonatomic) BOOL sortAscend;

@end

@implementation SortedImagesViewController

static NSString* const kPhotoCellIdentifier = @"PhotoCellIdentifier";


- (instancetype)initWithUser:(InstaUser *)user {
    self = [super init];
    
    if ( self ) {
        self.instagramUserID = user.userID;
        self.instagramUsername = user.username;
    }
    
    return self;
}

- (void)loadView {
    _rootView = [RecentImagesView new];
    self.view = _rootView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loadedData = [NSMutableArray new];
    _sortAscend = NO;
    _sortBy = @"likes";
    
    _rootView.tableView.dataSource = self;
    _rootView.tableView.delegate = self;
    
    _manager = [APIManager sharedManager];
    
    [self getAllImages];
    
    [self.rootView.tableView registerClass: [InstagramPhotoCell class]
                    forCellReuseIdentifier: kPhotoCellIdentifier];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem* sortButton =
    [[UIBarButtonItem alloc] initWithTitle:@"↓" style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonClick:)];
    UIBarButtonItem* choiceButton = [[UIBarButtonItem alloc] initWithTitle:@"Likes" style:UIBarButtonItemStylePlain target:self action:@selector(choiceButtonClick:)];
    
    [self.tabBarController.navigationItem setRightBarButtonItems:@[choiceButton, sortButton]];
    
    self.tabBarController.navigationItem.title = self.instagramUsername;
    //    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blueColor]};
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationItem setHidesBackButton:NO];
}

#pragma mark - API actions

- (void) getAllImages {
    __weak typeof(self) weakSelf = self;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"33", @"count", nil];

    __block void (^completionBlock)(NSMutableArray*, NSURL*) = ^(NSMutableArray* media, NSURL* nextURL){
        NSLog(@"Next url: %@ Count of media: %lu", nextURL, (unsigned long)media.count);
        if (nextURL) {
            [weakSelf.loadedData addObjectsFromArray:media];
            weakSelf.nextURL = nextURL;
            [weakSelf getAllImages];
        } else {
            [weakSelf.loadedData addObjectsFromArray:media];
            
            [weakSelf.loadedData sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"likes" ascending:NO]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.rootView.tableView reloadData];
            });
        }
    };
    if (!_nextURL) {
        [_manager getImagesWithUserID:_instagramUserID
                               params:params
                           completion:completionBlock];
    } else {
        [_manager getImagesWithURL:_nextURL completion:completionBlock];
    }
}

#pragma mark - Actions

- (void)choiceButtonClick:(UIBarButtonItem*)sender {
    if ( [_sortBy isEqualToString:@"commentsCount"] ) {
        _sortBy = @"likes";
        sender.title = @"Likes";
    } else {
        _sortBy = @"commentsCount";
        sender.title = @"Comments";
    }
    [self.loadedData sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:_sortBy ascending:_sortAscend]]];
    [self.rootView.tableView reloadData];
}

- (void)sortButtonClick:(UIBarButtonItem*)sender {
    if ( _sortAscend ) {
        _sortAscend = NO;
        sender.title = @"↓";
    } else {
        _sortAscend = YES;
        sender.title = @"↑";
    }
    [self.loadedData sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:_sortBy ascending:_sortAscend]]];
    [self.rootView.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_loadedData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InstagramPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:kPhotoCellIdentifier
                                                               forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [UIScreen mainScreen].bounds.size.width;
    
    CGSize maximumTextSize = CGSizeMake([UIScreen mainScreen].bounds.size.width-10, CGFLOAT_MAX);
    
    NSAttributedString *attributedString = [((MediaData*)_loadedData[indexPath.row]) attributedText];
    
    CGRect textRect = [attributedString boundingRectWithSize:maximumTextSize
                                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                     context:nil];
    
    height += textRect.size.height + 8;
    
    return height;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [((InstagramPhotoCell *)cell).photoImgView setImageWithURL:((MediaData*)_loadedData[indexPath.row]).photoURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    //NSLog(@"%@",((MediaData*)_loadedData[indexPath.row]).photoURL);
    
    ((InstagramPhotoCell *)cell).textView.tag = indexPath.row;
    ((InstagramPhotoCell *)cell).textView.attributedText = [(MediaData*)_loadedData[indexPath.row] attributedText];
    
    ((InstagramPhotoCell *)cell).textView.userInteractionEnabled = YES;
}

@end
