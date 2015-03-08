//
//  MCPageViewMacro.m
//  micmac
//
//  Created by Bryce Pauken on 2/23/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPageViewMacro.h"

#import "MCAPIHandler.h"
#import "MCButton.h"
#import "MCComposeView.h"
#import "MCGroupSelectionView.h"
#import "MCInitialMacroView.h"
#import "MCNavigationBar.h"
#import "MCOptionSignifierView.h"
#import "MCPointingView.h"
#import "MCPostTableView.h"
#import "MCSearchBar.h"
#import "MCSettingsManager.h"

@interface MCPageViewMacro()

@property (nonatomic, strong) MCInitialMacroView *initialView;
@property (nonatomic) BOOL initialViewInitialized;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) MCPostTableView *tableViewNew;
@property (nonatomic, strong) MCPostTableView *tableViewHot;

@end

@implementation MCPageViewMacro

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame name:@"Macro"];
    if(self) {
        __weak MCPageViewMacro *weakSelf = self;
        
        _sections = [NSMutableDictionary dictionaryWithObjectsAndKeys:@[],@"new", @[],@"hot", nil];
        
        [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Compose"]];
        [self.navigationBar setRightButtonTapped:^{
            [weakSelf showComposeView];
        }];
        [self.navigationBar setTitles:@[@"New Macro Posts", @"Hot Macro Posts", @"Trending Bubbles", @"Following Bubbles"]];
        
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
        
        if(![[MCSettingsManager settingForKey:@"macroSetupCompleted"] boolValue]) {
            _initialViewInitialized = NO;
            _initialView = [[MCInitialMacroView alloc] initWithFrame:self.contentView.bounds];
            __weak MCInitialMacroView *weakInitialView = _initialView;
            [_initialView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
            [_initialView setCompletionBlock:^(NSArray *groups) {
                [MCSettingsManager setSetting:[NSNumber numberWithBool:YES] forKey:@"macroSetupCompleted"];
                [weakInitialView setUserInteractionEnabled:NO];
                [UIView animateWithDuration:0.2 animations:^{
                    [weakInitialView setAlpha:0];
                    [weakInitialView setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
                }];
            }];
        }
        
        [self.contentView addSubview:_initialView];
    }
    return self;
}

- (void)hideComposeView:(MCComposeView *)composeView {
    __weak MCPageViewMacro *weakSelf = self;
    
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
    
    [self.scrollView setContentSize:CGSizeMake(self.contentView.bounds.size.width*4, self.contentView.bounds.size.height)];
    [self.scrollView setContentOffset:CGPointMake(self.contentView.bounds.size.width*self.scrollView.tag, 0)];
    [self.tableViewHot setFrame:CGRectMake(self.contentView.bounds.size.width, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
}

- (void)reloadPosts {
    __weak MCPageViewMacro *weakSelf = self;
    [MCAPIHandler makeRequestToFunction:@"Posts" components:@[@"macro", @"all"] parameters:nil completion:^(NSDictionary *data) {
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

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if(!hidden && self.initialView && !self.initialViewInitialized) {
        [self setInitialViewInitialized:YES];
        [self.initialView willShow];
        
        [MCAPIHandler makeRequestToFunction:@"Groups" components:@[@"initial"] parameters:nil completion:^(NSDictionary *data) {
            [self.initialView setGroups:[data objectForKey:@"groups"]];
        }];
    }
}

- (void)showComposeView {
    NSString *collegeName = [MCSettingsManager settingForKey:@"collegeName"];
    NSString *composePlaceholder = @"";
    if(collegeName.length) {
        composePlaceholder = [NSString stringWithFormat:@"New Post in %@'%@ Macro Section",collegeName,[collegeName hasSuffix:@"s"]?@"":@"s"];
    }
    MCComposeView *composeView = [[MCComposeView alloc] initInView:self.contentView withPlaceholder:composePlaceholder];
    
    __weak MCPageViewMacro *weakSelf = self;
    [self.navigationBar setLeftButtonImage:[UIImage imageNamed:@"Cancel"]];
    [self.navigationBar setLeftButtonTapped:^{
        [weakSelf hideComposeView:(MCComposeView *)composeView];
    }];
    [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Accept"]];
    [self.navigationBar setRightButtonTapped:^{
        [weakSelf hideComposeView:(MCComposeView *)composeView];
        [MCAPIHandler makeRequestToFunction:@"Post" components:@[@"macro"] parameters:@{@"post":[composeView text]} completion:^(NSDictionary *data) {
            
        }];
    }];
    
    [composeView show];
}

@end
