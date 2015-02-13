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

@implementation MCPageViewMicro

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame name:@"Micro"];
    if(self) {
        __weak MCPageViewMicro *weakSelf = self;
        
        [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Compose"]];
        [self.navigationBar setRightButtonTapped:^{
            [weakSelf showComposeView];
        }];
    }
    return self;
}

- (void)showComposeView {
    MCPointingView *pointingView = [[MCPointingView alloc] init];
    [pointingView show];
}

@end
