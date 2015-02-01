//
//  MCMainView.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCMainView.h"

#import "MCStartView.h"
#import "MCTabView.h"

@interface MCMainView()

@property (nonatomic, strong) MCStartView *startView;
@property (nonatomic, strong) MCTabView *tabView;

@end

@implementation MCMainView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _startView = [[MCStartView alloc] initWithFrame:self.bounds];
        __weak MCStartView *weakStartView = _startView;
        [_startView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [_startView setHiddenBlock:^{
            [weakStartView removeFromSuperview];
        }];
        
        _tabView = [[MCTabView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-70, self.bounds.size.width, 70)];
        [_tabView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [_tabView setButtonTapped:^(int index) {
            
        }];
        
        [self setBackgroundColor:[UIColor MCOffWhiteColor]];
        [self addSubview:_tabView];
        [self addSubview:_startView];
    }
    return self;
}

@end
