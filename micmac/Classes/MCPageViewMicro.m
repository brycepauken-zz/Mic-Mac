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

@property (nonatomic, strong) NSString *currentSection;
@property (nonatomic, strong) MCPointingView *pointingView;
@property (nonatomic, strong) MCPostTableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *sections;

@end

@implementation MCPageViewMicro

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame name:@"Micro"];
    if(self) {
        __weak MCPageViewMicro *weakSelf = self;
        
        _currentSection = @"new";
        _sections = [NSMutableDictionary dictionaryWithObjectsAndKeys:@[],@"new", @[],@"hot", nil];
        
        [self.navigationBar setDropDownBlock:^{
            weakSelf.pointingView = [[MCPointingView alloc] initWithFrame:CGRectMake(0, 0, 0, 60)];
            
            MCButton *newButton = [[MCButton alloc] initWithFrame:CGRectMake(0, 10, 100, 40)];
            [newButton addTarget:weakSelf action:@selector(dropDownButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [newButton setTag:0];
            [newButton setTitle:@"New"];
            [[weakSelf.pointingView contentView] addSubview:newButton];
            
            MCButton *hotButton = [[MCButton alloc] initWithFrame:CGRectMake([MCPointingView contentViewWidth]-100, 10, 100, 40)];
            [hotButton addTarget:weakSelf action:@selector(dropDownButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [hotButton setTag:1];
            [hotButton setTitle:@"Hot"];
            [[weakSelf.pointingView contentView] addSubview:hotButton];
            
            MCOptionSignifierView *optionSignifier = [[MCOptionSignifierView alloc] initWithFrame:CGRectMake(0, 0, [MCPointingView contentViewWidth]-210, 40)];
            [optionSignifier setCenter:CGPointMake([MCPointingView contentViewWidth]/2, 30)];
            [[weakSelf.pointingView contentView] addSubview:optionSignifier];
            
            [weakSelf.pointingView setPoint:CGPointMake(weakSelf.bounds.size.width/2, weakSelf.navigationBar.frame.origin.y+weakSelf.navigationBar.frame.size.height+10)];
            [weakSelf.pointingView show];
        }];
        [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Compose"]];
        [self.navigationBar setRightButtonTapped:^{
            [weakSelf showComposeView];
        }];
        
        _tableView = [[MCPostTableView alloc] initWithFrame:self.contentView.bounds];
        [_tableView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [_tableView setRefreshStarted:^{
            [weakSelf reloadPosts];
        }];
        [_tableView setPostsUpdated:^(NSArray *posts) {
            [weakSelf.sections setObject:posts forKey:weakSelf.currentSection];
        }];
        [self.contentView addSubview:_tableView];
        
        [self updateTitle];
    }
    return self;
}

- (void)dropDownButtonTapped:(UIButton *)button {
    if(self.pointingView) {
        [self.pointingView dismiss];
        [self setPointingView:nil];
    }
    [self setCurrentSection:(button.tag==0?@"new":@"hot")];
    [self updateTitle];
    [self.tableView setPosts:[self.sections objectForKey:self.currentSection]];
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

- (void)reloadPosts {
    __weak MCPageViewMicro *weakSelf = self;
    [MCAPIHandler makeRequestToFunction:@"Posts" components:@[@"micro", self.currentSection] parameters:nil completion:^(NSDictionary *data) {
        [weakSelf.tableView endRefresh];
        if(data) {
            [weakSelf.sections setObject:[data objectForKey:@"new"] forKey:@"new"];
            [weakSelf.sections setObject:[data objectForKey:@"hot"] forKey:@"hot"];
            [weakSelf.tableView setPosts:[weakSelf.sections objectForKey:weakSelf.currentSection]];
        }
    }];
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

- (void)updateTitle {
    [self.navigationBar setTitle:[NSString stringWithFormat:@"%@ Posts",[_currentSection capitalizedString]]];
}

@end
