//
//  MCOptionSignifierView.m
//  micmac
//
//  Created by Bryce Pauken on 2/28/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCOptionSignifierView.h"

@interface MCOptionSignifierView()

@property (nonatomic, strong) UIView *divider;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *labelBackground;

@end

@implementation MCOptionSignifierView

static const int kFontSize = 16;
static const int kLabelMargin = 5;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _divider = [[UIView alloc] initWithFrame:CGRectZero];
        [_divider setBackgroundColor:[UIColor MCOffWhiteColor]];
        
        _labelBackground = [[UILabel alloc] init];
        [_labelBackground setBackgroundColor:[UIColor MCMainColor]];
        
        _label = [[UILabel alloc] init];
        [_label setFont:[UIFont fontWithName:@"HoeflerText-Italic" size:kFontSize]];
        [_label setText:@"or"];
        [_label setTextColor:[UIColor MCOffWhiteColor]];
        [_label sizeToFit];
        
        [self setBackgroundColor:[UIColor MCMainColor]];
        
        [self addSubview:_divider];
        [self addSubview:_labelBackground];
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.divider setFrame:CGRectMake(0, self.bounds.size.height/2-1, self.bounds.size.width, 1)];
    [self.label setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    
    [self.labelBackground setFrame:CGRectMake((self.bounds.size.width-self.label.frame.size.width)/2-kLabelMargin, (self.bounds.size.height-self.label.frame.size.height)/2-kLabelMargin, self.label.frame.size.width+kLabelMargin*2, self.label.frame.size.height+kLabelMargin*2)];
}

- (void)setTitle:(NSString *)title {
    [self.label setText:title];
    [self.label sizeToFit];
    [self setNeedsLayout];
}

@end
