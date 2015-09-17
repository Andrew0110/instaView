//
//  ViewController.m
//  InstaView
//
//  Created by Andrew on 03.09.15.
//  Copyright (c) 2015 obodev.com. All rights reserved.
//

#import "ViewController.h"
#import "RootView.h"
#import "InstagramPhotoCell.h"
#import "APIManager.h"
#import "MediaData.h"
#import "UIImageView+AFNetworking.h"
#import <CoreText/CoreText.h>

@interface ViewController ()

@property (nonatomic) RootView* rootView;
@property (nonatomic) NSMutableArray* loadedData;
@property (nonatomic) APIManager* manager;
@property (nonatomic) NSString *instagramUserID;
@property (nonatomic) NSURL *nextURL;

@end

@implementation ViewController

- (instancetype)initWithUserId:(NSString *)userID {
    self = [super init];
    
    if ( self ) {
        self.instagramUserID = [NSString stringWithString:userID];
    }
    
    return self;
}

- (void)loadView {
    _rootView = [RootView new];
    self.view = _rootView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loadedData = [NSMutableArray new];
    
    _rootView.tableView.dataSource = self;
    _rootView.tableView.delegate = self;
    
    _manager = [APIManager sharedManager];
    //[_manager setBaseURL:[NSURL URLWithString:@"https://api.instagram.com/v1/"]];
    //_instagramUserID = @"2900367";
    [_manager setMethod:[NSString stringWithFormat:@"users/%@/media/recent/", _instagramUserID]];
    //[_manager setAccessToken:@"2162679026.a5e3084.7892c75453b04d4bac276f8f7c08d461"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"20", @"count", nil];
    
    [_manager requestWithParams:params completion:^(NSMutableArray *media, NSURL *nextURL) {
        [_loadedData addObjectsFromArray:media];
        _nextURL = nextURL;
        
        NSLog(@"count = %lu", (unsigned long)[media count]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootView.tableView reloadData];
        });
        
        //NSLog(@"%@, %ld", mediaData.photoURL, (long)mediaData.likes);
    }
    ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Actions

- (void) handleTapOnLabel:(UITapGestureRecognizer *)tapGesture {
    UILabel *label = (UILabel *)tapGesture.view;
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:label.attributedText];

    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    // Configure textContainer
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = label.lineBreakMode;
    textContainer.maximumNumberOfLines = label.numberOfLines;
    textContainer.size = label.bounds.size;

    CGPoint locationOfTouchInLabel = [tapGesture locationInView:tapGesture.view];
    CGSize labelSize = tapGesture.view.bounds.size;
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         locationOfTouchInLabel.y - textContainerOffset.y);
    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                            inTextContainer:textContainer
                                   fractionOfDistanceBetweenInsertionPoints:nil];
    NSRange linkRange = NSMakeRange(0, 5); // it's better to save the range somewhere when it was originally used for marking link in attributed string
    if (NSLocationInRange(indexOfCharacter, linkRange)) {
        // Open an URL, or handle the tap on the link in any other way
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://stackoverflow.com/"]];
        NSLog(@"Likes :)");
    }
    
    NSArray *values = ((MediaData*)_loadedData[label.tag]).ranges;
    
    for ( int i = 0; i < values.count; i++ ) {
        NSRange range = ((NSValue*)values[i]).rangeValue;
        if (NSLocationInRange(indexOfCharacter, range)) {
            
            ViewController* viewController = [[ViewController alloc] initWithUserId:((MediaData*)_loadedData[label.tag]).userCommentedIDs[i]];
            
            i = (int)values.count;
            
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
    }
 }

#pragma mark - API actions
- (void)loadNewImages {
    [_manager requestWithURL:_nextURL completion:^(NSMutableArray *media, NSURL *nextURL) {
        [_loadedData addObjectsFromArray:media];
        _nextURL = nextURL;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootView.tableView reloadData];
        });
        
        //NSLog(@"%@, %ld", mediaData.photoURL, (long)mediaData.likes);
    }
    ];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_loadedData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"PhotoCell";
    InstagramPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( indexPath.row == (_loadedData.count - 7) ) {
        [self loadNewImages];
    }
    
    if (!cell) {
        cell = [InstagramPhotoCell new];
    }
    
    [cell.photoImgView setImageWithURL:((MediaData*)_loadedData[indexPath.row]).photoURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    NSLog(@"%@",((MediaData*)_loadedData[indexPath.row]).photoURL);
    
    cell.likesLabel.tag = indexPath.row;
    cell.likesLabel.attributedText = [(MediaData*)_loadedData[indexPath.row] getAttributedText];
    
    cell.likesLabel.userInteractionEnabled = YES;
    [cell.likesLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [UIScreen mainScreen].bounds.size.width;
    UIFont *fontText = [UIFont systemFontOfSize:12];
    // you can use your font.
    
    CGSize maximumLabelSize = CGSizeMake(height-5, CGFLOAT_MAX);
    
    NSAttributedString *attributedString = [((MediaData*)_loadedData[indexPath.row]) getAttributedText];
    
    CGRect textRect = [attributedString.string boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:fontText}
                                             context:nil];
    
    height += textRect.size.height + 8;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}


@end
