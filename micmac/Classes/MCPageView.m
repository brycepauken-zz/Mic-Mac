//
//  MCPageView.m
//  micmac
//
//  Created by Bryce Pauken on 2/1/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPageView.h"

#import "MCNavigationBar.h"

@interface MCPageView()

@property (nonatomic, strong) NSString *name;

@end

@implementation MCPageView

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name {
    self = [super initWithFrame:frame];
    if(self) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.bounds.size.width, self.bounds.size.height-60)];
        
        _navigationBar = [[MCNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 60)];
        [_navigationBar setTitle:name];
        
        [self setBackgroundColor:[UIColor MCOffWhiteColor]];
        [self addSubview:_contentView];
        [self addSubview:_navigationBar];
    }
    return self;
}

- (void)layoutSubviews {
    [self.contentView setFrame:CGRectMake(0, 60, self.bounds.size.width, self.bounds.size.height-60)];
    [self.navigationBar setFrame:CGRectMake(0, 0, self.bounds.size.width, 60)];
}

@end
