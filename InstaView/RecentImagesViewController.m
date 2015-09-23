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
#import <CoreText/CoreText.h>

@interface RecentImagesViewController ()

@property (nonatomic) RecentImagesView* rootView;
@property (nonatomic) NSMutableArray* loadedData;
@property (nonatomic) APIManager* manager;
@property (nonatomic) NSString *instagramUserID;
@property (nonatomic) NSURL *nextURL;

@end

@implementation RecentImagesViewController

static NSString* const kPhotoCellIdentifier = @"PhotoCellIdentifier";

- (instancetype)initWithUserId:(NSString *)userID {
    self = [super init];
    
    if ( self ) {
        self.instagramUserID = [NSString stringWithString:userID];
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
    [_manager setMethod:[NSString stringWithFormat:@"users/%@/media/recent/", _instagramUserID]];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"20", @"count", nil];
    
    [_manager getImagesWithParams:params completion:^(NSMutableArray *media, NSURL *nextURL) {
        [_loadedData addObjectsFromArray:media];
        _nextURL = nextURL;
        
        NSLog(@"count = %lu", (unsigned long)[media count]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootView.tableView reloadData];
        });
    }
    ];
    [self.rootView.tableView registerClass: [InstagramPhotoCell class]
                      forCellReuseIdentifier: kPhotoCellIdentifier];
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
    
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = label.lineBreakMode;
    textContainer.maximumNumberOfLines = label.numberOfLines;
    textContainer.widthTracksTextView = YES;
    textContainer.size = label.bounds.size;

    CGPoint locationOfTouchInLabel = [tapGesture locationInView:label];
    CGSize labelSize = tapGesture.view.bounds.size;
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         locationOfTouchInLabel.y - textContainerOffset.y);

    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                            inTextContainer:textContainer
                                   fractionOfDistanceBetweenInsertionPoints:nil];
    NSLog(@"index = %ld, letter = %hu", (long)indexOfCharacter, [label.attributedText.string characterAtIndex:indexOfCharacter]);
    NSRange likesRange = NSMakeRange(0, 5);
    if (NSLocationInRange(indexOfCharacter, likesRange)) {
        NSLog(@"Likes :)");
    }
    
    NSArray *values = ((MediaData*)_loadedData[label.tag]).ranges;
    
    for ( int i = 0; i < values.count; i++ ) {
        NSRange range = ((NSValue*)values[i]).rangeValue;
        if (NSLocationInRange(indexOfCharacter, range)) {
            
            RecentImagesViewController* viewController = [[RecentImagesViewController alloc] initWithUserId:((MediaData*)_loadedData[label.tag]).userCommentedIDs[i]];
            
            i = (int)values.count;
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
 }

- (void) handleTapOnTextView:(UITapGestureRecognizer *)tapGesture {
    
    UITextView *textView = (UITextView *)tapGesture.view;
    
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [tapGesture locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSUInteger indexOfCharacter;
    indexOfCharacter = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    
    NSRange likesRange = NSMakeRange(0, 5);
    if (NSLocationInRange(indexOfCharacter, likesRange)) {
        NSLog(@"Likes :)");
    }
    
    NSArray *values = ((MediaData*)_loadedData[textView.tag]).ranges;
    
    for ( int i = 0; i < values.count; i++ ) {
        NSRange range = ((NSValue*)values[i]).rangeValue;
        if (NSLocationInRange(indexOfCharacter, range)) {
            
            RecentImagesViewController* viewController = [[RecentImagesViewController alloc] initWithUserId:((MediaData*)_loadedData[textView.tag]).userCommentedIDs[i]];
            
            i = (int)values.count;
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}


#pragma mark - API actions
- (void)loadNewImages {
    [_manager getImagesWithURL:_nextURL completion:^(NSMutableArray *media, NSURL *nextURL) {
        [_loadedData addObjectsFromArray:media];
        _nextURL = nextURL;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootView.tableView reloadData];
        });
    }
    ];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_loadedData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InstagramPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [UIScreen mainScreen].bounds.size.width;
    
    CGSize maximumTextSize = CGSizeMake([UIScreen mainScreen].bounds.size.width-10, CGFLOAT_MAX);
    
    NSAttributedString *attributedString = [((MediaData*)_loadedData[indexPath.row]) getAttributedText];
    
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
    NSLog(@"%@",((MediaData*)_loadedData[indexPath.row]).photoURL);
    
    ((InstagramPhotoCell *)cell).textView.tag = indexPath.row;
    ((InstagramPhotoCell *)cell).textView.attributedText = [(MediaData*)_loadedData[indexPath.row] getAttributedText];
    
    ((InstagramPhotoCell *)cell).textView.userInteractionEnabled = YES;
    [((InstagramPhotoCell *)cell).textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnTextView:)]];
    
}

@end
