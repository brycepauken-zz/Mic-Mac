//
//  MCMainView.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCMainView.h"

#import "MCStartView.h"

@interface MCMainView()

@property (nonatomic, strong) MCStartView *startView;

@end

@implementation MCMainView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _startView = [[MCStartView alloc] initWithFrame:self.bounds];
        [_startView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        
        [self addSubview:_startView];
    }
    return self;
}

@end
