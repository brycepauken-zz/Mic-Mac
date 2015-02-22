//
//  MCPageMicroView.m
//  micmac
//
//  Created by Bryce Pauken on 2/12/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPageViewMicro.h"

#import "MCNavigationBar.h"
#import "MCPointingView.h"
#import "MCPostTableView.h"

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

- (void)showComposeView {
    MCPointingView *pointingView = [[MCPointingView alloc] init];
    [pointingView show];
}

@end
