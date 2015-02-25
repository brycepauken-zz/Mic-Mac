//
//  MCGroupButton.m
//  micmac
//
//  Created by Bryce Pauken on 2/24/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCGroupButton.h"

@interface MCGroupButton()

@property (nonatomic, strong) UILabel *label;

@end

@implementation MCGroupButton

static const int kButtonBorderThickness = 2;
static const int kButtonCornerRadius = 4;
static const int kButtonHeight = 38;
static const int kButtonHorizontalMargins = 8;
static const int kLabelFontSize = 16;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _label = [[UILabel alloc] init];
        [_label setFont:[UIFont fontWithName:@"Avenir-Heavy" size:kLabelFontSize]];
        [_label setTextColor:[UIColor MCOffWhiteColor]];
        
        [self setBackgroundColor:[UIColor MCMainColor]];
        [self.layer setBorderColor:[UIColor MCOffWhiteColor].CGColor];
        [self.layer setBorderWidth:kButtonBorderThickness];
        [self.layer setCornerRadius:kButtonCornerRadius];
        [self.layer setMasksToBounds:YES];
        
        [self addSubview:_label];
    }
    return self;
}

+ (int)buttonHeight {
    return kButtonHeight;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self.label setTextColor:(highlighted||self.selected?[UIColor MCMainColor]:[UIColor MCOffWhiteColor])];
    [self setBackgroundColor:(highlighted||self.selected?[UIColor MCOffWhiteColor]:[UIColor MCMainColor])];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self.label setTextColor:(selected||self.highlighted?[UIColor MCMainColor]:[UIColor MCOffWhiteColor])];
    [self setBackgroundColor:(selected||self.highlighted?[UIColor MCOffWhiteColor]:[UIColor MCMainColor])];
}

- (void)setTitleAndReframe:(NSString *)title {
    [self.label setText:[title uppercaseString]];
    [self.label sizeToFit];
    [self setFrame:CGRectMake(0, 0, self.label.frame.size.width+kButtonHorizontalMargins*2, kButtonHeight)];
    [self.label setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
}

@end
