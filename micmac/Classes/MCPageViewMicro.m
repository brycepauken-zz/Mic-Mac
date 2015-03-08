//
//  MCPageMicroView.m
//  micmac
//
//  Created by Bryce Pauken on 2/12/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPageViewMicro.h"

#import "MCAPIHandler.h"
#import "MCButton.h"
#import "MCComposeView.h"
#import "MCNavigationBar.h"
#import "MCOptionSignifierView.h"
#import "MCPointingView.h"
#import "MCPostTableView.h"
#import "MCSettingsManager.h"

@interface MCPageViewMicro()

@property (nonatomic, strong) MCPointingView *pointingView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) MCPostTableView *tableViewNew;
@property (nonatomic, strong) MCPostTableView *tableViewHot;

@end

@implementation MCPageViewMicro

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame name:@"Micro"];
    if(self) {
        __weak MCPageViewMicro *weakSelf = self;
        
        _sections = [NSMutableDictionary dictionaryWithObjectsAndKeys:@[],@"new", @[],@"hot", nil];
        
        [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Compose"]];
        [self.navigationBar setRightButtonTapped:^{
            [weakSelf showComposeView];
        }];
        [self.navigationBar setTitles:@[@"New Posts", @"Hot Posts"]];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
        [_scrollView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [_scrollView setBackgroundColor:[UIColor colorWithWhite:0.925 alpha:1]];
        [_scrollView setDelegate:self];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [self.contentView addSubview:_scrollView];
        
        _tableViewNew = [[MCPostTableView alloc] initWithFrame:self.contentView.bounds];
        [_tableViewNew setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [_tableViewNew setRefreshStarted:^{
            [weakSelf.tableViewHot showRefreshIndicator];
            [weakSelf reloadPosts];
        }];
        [_tableViewNew setPostsUpdated:^(NSArray *posts) {
            [weakSelf.sections setObject:posts forKey:@"new"];
        }];
        [_scrollView addSubview:_tableViewNew];
        
        _tableViewHot = [[MCPostTableView alloc] init];
        [_tableViewHot setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [_tableViewHot setRefreshStarted:^{
            [weakSelf.tableViewNew showRefreshIndicator];
            [weakSelf reloadPosts];
        }];
        [_tableViewHot setPostsUpdated:^(NSArray *posts) {
            [weakSelf.sections setObject:posts forKey:@"hot"];
        }];
        [_scrollView addSubview:_tableViewHot];
    }
    return self;
}

- (void)hideComposeView:(MCComposeView *)composeView {
    __weak MCPageViewMicro *weakSelf = self;
    
    [self.navigationBar setLeftButtonImage:nil];
    [self.navigationBar setLeftButtonTapped:nil];
    [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Compose"]];
    [self.navigationBar setRightButtonTapped:^{
        [weakSelf showComposeView];
    }];
    
    [composeView dismiss];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.scrollView setContentSize:CGSizeMake(self.contentView.bounds.size.width*2, self.contentView.bounds.size.height)];
    [self.scrollView setContentOffset:CGPointMake(self.contentView.bounds.size.width*self.scrollView.tag, 0)];
    [self.tableViewHot setFrame:CGRectMake(self.contentView.bounds.size.width, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
}

- (void)reloadPosts {
    __weak MCPageViewMicro *weakSelf = self;
    [MCAPIHandler makeRequestToFunction:@"Posts" components:@[@"micro"] parameters:nil completion:^(NSDictionary *data) {
        [weakSelf.tableViewNew endRefresh];
        [weakSelf.tableViewHot endRefresh];
        if(data) {
            [weakSelf.sections setObject:[data objectForKey:@"new"] forKey:@"new"];
            [weakSelf.sections setObject:[data objectForKey:@"hot"] forKey:@"hot"];
            [weakSelf.tableViewNew setPosts:[weakSelf.sections objectForKey:@"new"]];
            [weakSelf.tableViewHot setPosts:[weakSelf.sections objectForKey:@"hot"]];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollFactor = scrollView.contentOffset.x/scrollView.bounds.size.width;
    [self.navigationBar setScrollFactor:scrollFactor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger page = (int)(scrollFactor + 0.5);
        [self.scrollView setTag:page];
        [self.navigationBar setPage:page];
    });
}

- (void)showComposeView {
    NSString *collegeName = [MCSettingsManager settingForKey:@"collegeName"];
    NSString *composePlaceholder = @"";
    if(collegeName.length) {
        composePlaceholder = [NSString stringWithFormat:@"New Post in %@'%@ Micro Section",collegeName,[collegeName hasSuffix:@"s"]?@"":@"s"];
    }
    MCComposeView *composeView = [[MCComposeView alloc] initInView:self.contentView withPlaceholder:composePlaceholder];
    
    __weak MCPageViewMicro *weakSelf = self;
    [self.navigationBar setLeftButtonImage:[UIImage imageNamed:@"Cancel"]];
    [self.navigationBar setLeftButtonTapped:^{
        [weakSelf hideComposeView:(MCComposeView *)composeView];
    }];
    [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Accept"]];
    [self.navigationBar setRightButtonTapped:^{
        [weakSelf hideComposeView:(MCComposeView *)composeView];
        [MCAPIHandler makeRequestToFunction:@"Post" components:@[@"micro"] parameters:@{@"post":[composeView text]} completion:^(NSDictionary *data) {
            
        }];
    }];
    
    [composeView show];
}

@end
