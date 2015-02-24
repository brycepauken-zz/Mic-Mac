//
//  MCPageViewMacro.m
//  micmac
//
//  Created by Bryce Pauken on 2/23/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPageViewMacro.h"

#import "MCAPIHandler.h"
#import "MCComposeView.h"
#import "MCInitialMacroView.h"
#import "MCNavigationBar.h"
#import "MCPostTableView.h"
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
        
        [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Compose"]];
        [self.navigationBar setRightButtonTapped:^{
            [weakSelf showComposeView];
        }];
        
        _tableView = [[MCPostTableView alloc] initWithFrame:self.contentView.bounds];
        [_tableView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [self.contentView addSubview:_tableView];
        
        _initialViewInitialized = NO;
        _initialView = [[MCInitialMacroView alloc] initWithFrame:self.contentView.bounds];
        [_initialView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        
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
    [MCAPIHandler makeRequestToFunction:@"Posts" components:@[@"macro", @"new"] parameters:nil completion:^(NSDictionary *data) {
        [weakSelf.tableView setPosts:[data objectForKey:@"posts"]];
    }];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if(!hidden && self.initialView && !self.initialViewInitialized) {
        [self setInitialViewInitialized:YES];
        
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
