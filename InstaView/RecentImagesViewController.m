//
//  ViewController.m
//  InstaView
//
//  Created by Andrew on 03.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "RecentImagesViewController.h"
#import "RecentImagesView.h"
#import "InstagramPhotoCell.h"
#import "APIManager.h"
#import "MediaData.h"
#import "UIImageView+AFNetworking.h"
#import "InstaUser.h"
#import <CoreText/CoreText.h>

@interface RecentImagesViewController () <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>

@property (nonatomic) RecentImagesView* rootView;
@property (nonatomic) APIManager* manager;
@property (nonatomic) NSMutableArray* loadedData;
@property (nonatomic) NSString *instagramUserID;
@property (nonatomic) NSString *instagramUsername;
@property (nonatomic) NSURL *nextURL;

@end

@implementation RecentImagesViewController

static NSString* const kPhotoCellIdentifier = @"PhotoCellIdentifier";

- (instancetype)initWithUser:(InstaUser *)user {
    self = [super init];
    
    if ( self ) {
        self.instagramUserID = user.userID;
        self.instagramUsername = user.username;
    }
    
    return self;
}

- (instancetype)initWithUserID:(NSString *)userID
{
    self = [super init];
    if (self) {
        self.instagramUserID = userID;
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
    
    _rootView.tableView.dataSource = self;
    _rootView.tableView.delegate = self;
    
    _manager = [APIManager sharedManager];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"33", @"count", nil];
    
    __weak typeof(self) weakSelf = self;
    
    [_manager getImagesWithUserID:_instagramUserID
                           params:params
                       completion:^(NSMutableArray *media, NSURL *nextURL)
    {
        [_loadedData addObjectsFromArray:media];
        weakSelf.nextURL = nextURL;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.rootView.tableView reloadData];
        });
    }
    ];
    
    [self.rootView.tableView registerClass: [InstagramPhotoCell class]
                      forCellReuseIdentifier: kPhotoCellIdentifier];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tabBarController.navigationItem setRightBarButtonItems:nil];
    
    self.tabBarController.navigationItem.title = self.instagramUsername;
    [self.navigationController setNavigationBarHidden:NO];

    [self.navigationItem setHidesBackButton:NO];
}

#pragma mark - Actions

//- (void) handleTapOnLabel:(UITapGestureRecognizer *)sender {
//    UILabel *label = (UILabel *)sender.view;
//    
//    NSLayoutManager *layoutManager = [NSLayoutManager new];
//    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
//    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:label.attributedText];
//
//    [layoutManager addTextContainer:textContainer];
//    [textStorage addLayoutManager:layoutManager];
//    
//    textContainer.lineFragmentPadding = 0.0;
//    textContainer.lineBreakMode = label.lineBreakMode;
//    textContainer.maximumNumberOfLines = label.numberOfLines;
//    textContainer.widthTracksTextView = YES;
//    textContainer.size = label.bounds.size;
//
//    CGPoint locationOfTouchInLabel = [sender locationInView:label];
//    CGSize labelSize = sender.view.bounds.size;
//    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
//    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
//                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
//    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
//                                                         locationOfTouchInLabel.y - textContainerOffset.y);
//
//    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer
//                                                            inTextContainer:textContainer
//                                   fractionOfDistanceBetweenInsertionPoints:nil];
//    NSLog(@"index = %ld, letter = %hu", (long)indexOfCharacter, [label.attributedText.string characterAtIndex:indexOfCharacter]);
//    NSRange likesRange = NSMakeRange(0, 5);
//    if (NSLocationInRange(indexOfCharacter, likesRange)) {
//        NSLog(@"Likes :)");
//    }
//    
//    NSArray *values = ((MediaData*)_loadedData[label.tag]).ranges;
//    
//    for ( int i = 0; i < values.count; i++ ) {
//        NSRange range = ((NSValue*)values[i]).rangeValue;
//        if (NSLocationInRange(indexOfCharacter, range)) {
//            
//            RecentImagesViewController* viewController = [[RecentImagesViewController alloc] initWithUserId:((MediaData*)_loadedData[label.tag]).userCommentedIDs[i]];
//            
//            i = (int)values.count;
//            
//            [self.navigationController pushViewController:viewController animated:YES];
//        }
//    }
// }

- (void) handleTapOnTextView:(UITapGestureRecognizer *)tapGesture {
    UITextView *textView = (UITextView *)tapGesture.view;
    
    CGPoint location = [tapGesture locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSUInteger indexOfCharacter = [textView.layoutManager characterIndexForPoint:location
                                                                 inTextContainer:textView.textContainer
                                        fractionOfDistanceBetweenInsertionPoints:NULL];
    
    [((MediaData*)_loadedData[textView.tag]).ranges enumerateObjectsUsingBlock:^(NSValue *value,
                                                                                 NSUInteger idx,
                                                                                 BOOL *stop)
    {
        if (NSLocationInRange(indexOfCharacter, value.rangeValue)) {
            
            NSString *userID = ((MediaData*)_loadedData[textView.tag]).userCommentedIDs[idx];
            if (![userID isEqualToString:self.instagramUserID]) {
                RecentImagesViewController* viewController = [[RecentImagesViewController alloc] initWithUserID:userID];
                [self.navigationController pushViewController:viewController animated:YES];
            }
            *stop = YES;
        }
    }];
}

#pragma mark - API actions
- (void)loadNewImages {
    if (_nextURL) {
        [_manager getImagesWithURL:_nextURL
                        completion:^(NSMutableArray *media, NSURL *nextURL)
        {
            [_loadedData addObjectsFromArray:media];
            if (nextURL)
                _nextURL = nextURL;
            else
                _nextURL = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.rootView.tableView reloadData];
            });
        }
        ];
    }
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.row == (_loadedData.count - 7) && _nextURL) {
        [self loadNewImages];
    }
    
    [((InstagramPhotoCell *)cell).photoImgView setImageWithURL:((MediaData*)_loadedData[indexPath.row]).photoURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    //NSLog(@"%@",((MediaData*)_loadedData[indexPath.row]).photoURL);
    
    ((InstagramPhotoCell *)cell).textView.tag = indexPath.row;
    ((InstagramPhotoCell *)cell).textView.attributedText = [(MediaData*)_loadedData[indexPath.row] attributedText];
    
    ((InstagramPhotoCell *)cell).textView.userInteractionEnabled = YES;
    [((InstagramPhotoCell *)cell).textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnTextView:)]];
}

@end
