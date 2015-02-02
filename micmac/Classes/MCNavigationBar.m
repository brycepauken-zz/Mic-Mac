//
//  MCNavigationBar.m
//  micmac
//
//  Created by Bryce Pauken on 2/1/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCNavigationBar.h"

@interface MCNavigationBar()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MCNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/4, 20, self.bounds.size.width/2, self.bounds.size.height-20)];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [_titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor MCOffWhiteColor]];
        
        [self setBackgroundColor:[UIColor MCMainColor]];
        
        [self addSubview:_titleLabel];
    }
    return  self;
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

@end
