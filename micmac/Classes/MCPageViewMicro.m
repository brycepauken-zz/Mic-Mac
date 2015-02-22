//
//  MCPageMicroView.m
//  micmac
//
//  Created by Bryce Pauken on 2/12/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPageViewMicro.h"

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
        
        NSArray *examplePosts = @[
                                  @{@"Post":@"Hello World",@"Points":@(99)},
                                  @{@"Post":@"Some long text with the goal of establishing how to handle lenghty posts",@"Points":@(0)},
                                  @{@"Post":@"This is not valuable. Negative Points!",@"Points":@(-2)},
                                  @{@"Post":@"Coming up with these things is harder than you'd think,",@"Points":@(1)},
                                  @{@"Post":@"at least it is for me,",@"Points":@(1)},
                                  @{@"Post":@"but I have to keep going so I can see how these tableviews work when nearing the tab bar. This is another fine example of a lengthy post.",@"Points":@(2)},
                                  @{@"Post":@"Actual posts probably won't be as long as that though. Have we decided on a character limit?",@"Points":@(0)}
                                  ];
        [_tableView setPosts:examplePosts];
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
    }];
    
    [composeView show];
}

@end
