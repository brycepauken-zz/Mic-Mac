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
        _navigationBar = [[MCNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 60)];
        [_navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
        [_navigationBar setTitle:name];
        
        [self setBackgroundColor:[UIColor MCOffWhiteColor]];
        
        [self addSubview:_navigationBar];
    }
    return self;
}

@end
