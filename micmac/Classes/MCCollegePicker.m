//
//  MCCollegePicker.m
//  micmac
//
//  Created by Bryce Pauken on 12/29/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCCollegePicker.h"

@interface MCCollegePicker()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation MCCollegePicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_spinner setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
        [_spinner setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        
        [self setBackgroundColor:[UIColor MCLightBlueColor]];
        [self addSubview:_spinner];
        
        [_spinner startAnimating];
    }
    return self;
}

@end
