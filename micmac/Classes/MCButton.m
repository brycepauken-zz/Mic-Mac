//
//  MCButton.m
//  micmac
//
//  Created by Bryce Pauken on 12/28/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCButton.h"

@interface MCButton()

@property (nonatomic, strong) UILabel *label;

@end

@implementation MCButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _label = [[UILabel alloc] init];
        [_label setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
        [_label setFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setTextColor:[UIColor MCOffWhiteColor]];
        
        [self setBackgroundColor:[UIColor MCMainColor]];
        [self.layer setBorderColor:[UIColor MCOffWhiteColor].CGColor];
        [self.layer setBorderWidth:2];
        [self.layer setCornerRadius:4];
        
        [self addSubview:_label];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if(highlighted) {
        [self.layer setBorderColor:[[UIColor MCOffWhiteColor] colorWithAlphaComponent:0.5].CGColor];
        [self.label setTextColor:[[UIColor MCOffWhiteColor] colorWithAlphaComponent:0.5]];
    }
    else {
        [self.layer setBorderColor:[UIColor MCOffWhiteColor].CGColor];
        [self.label setTextColor:[UIColor MCOffWhiteColor]];
    }
}

- (void)setTitle:(NSString *)title {
    [self.label setText:[title uppercaseString]];
    [self.label sizeToFit];
    [self.label setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
}

@end
