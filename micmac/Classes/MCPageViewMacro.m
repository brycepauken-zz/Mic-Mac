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
@property (nonatomic, strong) MCPostTableView *tableView;

@end

@implementation MCPageViewMacro

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame name:@"Macro"];
    if(self) {
        __weak MCPageViewMacro *weakSelf = self;
        
        [self.navigationBar setDropDownBlock:^{
            MCPointingView *pointingView = [[MCPointingView alloc] initWithFrame:CGRectMake(0, 0, 0, 220)];
            
            MCButton *newButton = [[MCButton alloc] initWithFrame:CGRectMake(0, 10, 100, 40)];
            [newButton setTitle:@"View All\nPosts"];
            [newButton setTitleSize:12];
            [[pointingView contentView] addSubview:newButton];
            
            MCButton *hotButton = [[MCButton alloc] initWithFrame:CGRectMake([MCPointingView contentViewWidth]-100, 10, 100, 40)];
            [hotButton setTitle:@"Discover\nBubbles"];
            [hotButton setTitleSize:12];
            [[pointingView contentView] addSubview:hotButton];
            
            MCOptionSignifierView *optionSignifier = [[MCOptionSignifierView alloc] initWithFrame:CGRectMake(0, 0, [MCPointingView contentViewWidth]-210, 40)];
            [optionSignifier setCenter:CGPointMake([MCPointingView contentViewWidth]/2, 30)];
            [[pointingView contentView] addSubview:optionSignifier];
            
            MCOptionSignifierView *optionSignifierBottom = [[MCOptionSignifierView alloc] initWithFrame:CGRectMake(0, 0, [MCPointingView contentViewWidth]-20, 40)];
            [optionSignifierBottom setCenter:CGPointMake([MCPointingView contentViewWidth]/2, 70)];
            [optionSignifierBottom setTitle:@"or search for a bubble"];
            [[pointingView contentView] addSubview:optionSignifierBottom];
            
            MCSearchBar *searchBar = [[MCSearchBar alloc] initWithFrame:CGRectMake(10, 90, [MCPointingView contentViewWidth]-20, 30)];
            [[pointingView contentView] addSubview:searchBar];
            
            MCGroupSelectionView *groupSelectionView = [[MCGroupSelectionView alloc] initWithFrame:CGRectMake(0, 125, [MCPointingView contentViewWidth], 100)];
            [[pointingView contentView] addSubview:groupSelectionView];
            
            [MCAPIHandler makeRequestToFunction:@"Groups" components:@[@"initial"] parameters:nil completion:^(NSDictionary *data) {
                [groupSelectionView setGroups:[data objectForKey:@"groups"]];
            }];
            
            [pointingView setPoint:CGPointMake(weakSelf.bounds.size.width/2, weakSelf.navigationBar.frame.origin.y+weakSelf.navigationBar.frame.size.height+10)];
            [pointingView show];
        }];
        [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Compose"]];
        [self.navigationBar setRightButtonTapped:^{
            [weakSelf showComposeView];
        }];
        
        _tableView = [[MCPostTableView alloc] initWithFrame:self.contentView.bounds];
        [_tableView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [self.contentView addSubview:_tableView];
        
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
        
        [self.contentView addSubview:_tableView];
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

- (void)reloadPosts {
    __weak MCPageViewMacro *weakSelf = self;
    [MCAPIHandler makeRequestToFunction:@"Posts" components:@[@"macro", @"all", @"new"] parameters:nil completion:^(NSDictionary *data) {
        [weakSelf.tableView setPosts:[data objectForKey:@"posts"]];
    }];
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
