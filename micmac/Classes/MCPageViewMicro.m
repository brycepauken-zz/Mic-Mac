//
//  MCPageMicroView.m
//  micmac
//
//  Created by Bryce Pauken on 2/12/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPageViewMicro.h"

#import "MCAPIHandler.h"
#import "MCComposeView.h"
#import "MCNavigationBar.h"
#import "MCPostTableView.h"
#import "MCSettingsManager.h"

@interface MCPageViewMicro()

@property (nonatomic, strong) MCPostTableView *tableView;

@end

@implementation MCPageViewMicro

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame name:@"Micro"];
    if(self) {
        __weak MCPageViewMicro *weakSelf = self;
        
        [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Compose"]];
        [self.navigationBar setRightButtonTapped:^{
            [weakSelf showComposeView];
        }];
        
        _tableView = [[MCPostTableView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_tableView];
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

- (void)reloadPosts {
    __weak MCPageViewMicro *weakSelf = self;
    [MCAPIHandler makeRequestToFunction:@"Posts" components:@[@"micro", @"new"] parameters:nil completion:^(NSDictionary *data) {
        [weakSelf.tableView setPosts:[data objectForKey:@"posts"]];
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

@end
