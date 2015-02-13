//
//  MCPageMicroView.m
//  micmac
//
//  Created by Bryce Pauken on 2/12/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPageViewMicro.h"

#import "MCNavigationBar.h"

@implementation MCPageViewMicro

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame name:@"Micro"];
    if(self) {
        [self.navigationBar setRightButtonImage:[UIImage imageNamed:@"Compose"]];
    }
    return self;
}

@end
