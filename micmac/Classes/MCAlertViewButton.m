//
//  MCAlertViewButton.m
//  micmac
//
//  Created by Bryce Pauken on 1/30/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCAlertViewButton.h"

@interface MCAlertViewButton()

@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIColor *normalBackgroundColor;

@end

@implementation MCAlertViewButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setHighlightedBackgroundColor:[UIColor lightGrayColor]];
        [self setNormalBackgroundColor:[UIColor MCOffWhiteColor]];
        [self.layer setCornerRadius:2];
        [self.layer setMasksToBounds:YES];
        
        self.iconImageView = [[UIImageView alloc] init];
        [self.iconImageView setAlpha:0.75];
        [self addSubview:self.iconImageView];
        
        self.label = [[UILabel alloc] init];
        [self.label setAlpha:0.75];
        [self.label setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setTextColor:[UIColor blackColor]];
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    static int iconSize = 16;
    static int padding = 16;
    
    CGSize titleLabelSize = [self.label.text sizeWithFont:self.label.font constrainedToWidth:self.bounds.size.width];
    
    CGFloat totalContentWidth = self.iconImageView.image?titleLabelSize.width+padding+iconSize:titleLabelSize.width;
    [self.label setFrame:CGRectMake((self.bounds.size.width-totalContentWidth)/2, (self.bounds.size.height-titleLabelSize.height)/2, titleLabelSize.width, titleLabelSize.height)];
    [self.iconImageView setFrame:CGRectMake(self.label.frame.origin.x+self.label.frame.size.width+padding, (self.bounds.size.height-iconSize)/2, iconSize, iconSize)];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self.iconImageView setAlpha:enabled?1:0.5];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self setBackgroundColor:highlighted?self.highlightedBackgroundColor:self.normalBackgroundColor];
}

- (void)setImage:(UIImage *)image {
    [self.iconImageView setImage:image];
}

- (void)setTitle:(NSString *)title {
    [self.label setText:[title uppercaseString]];
    [self setNeedsLayout];
}

@end
