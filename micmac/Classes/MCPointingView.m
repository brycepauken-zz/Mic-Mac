//
//  MCPointingView.m
//  micmac
//
//  Created by Bryce Pauken on 2/12/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPointingView.h"

#import "MCMainView.h"

@interface MCPointingView()

@property (nonatomic) CGPoint point;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, copy) void (^tappedBlock)();
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MCPointingView

static const int kPointingViewArrowHeight = 8;
static const int kPointingViewArrowWidth = 16;
static const int kPointingViewBorderSize = 8;
static const int kPointingViewCornerRadius = 4;
static const int kPointingViewFontSize = 14;
static const int kPointingViewHorizontalMargin = 10;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        [_shapeLayer setFillColor:[UIColor MCOffWhiteColor].CGColor];
        [_shapeLayer setShadowColor:[UIColor MCOffBlackColor].CGColor];
        [_shapeLayer setShadowOffset:CGSizeMake(0, 0)];
        [_shapeLayer setShadowOpacity:1];
        [_shapeLayer setShadowRadius:1];
        [self.layer insertSublayer:_shapeLayer atIndex:0];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setBackgroundColor:[UIColor MCOffWhiteColor]];
        [_titleLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:kPointingViewFontSize]];
        [_titleLabel setTextColor:[UIColor MCMainColor]];
        [self addSubview:_titleLabel];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)dismiss {
    [self setUserInteractionEnabled:NO];
    [self removeFromSuperview];
}

- (void)layoutSubviews {
    CGFloat horizontalOffset = self.point.x-self.titleLabel.frame.size.width/2-kPointingViewBorderSize;
    CGFloat width = self.titleLabel.frame.size.width+kPointingViewBorderSize*2;
    
    CGFloat superviewWidth = self.superview.bounds.size.width;
    if([self.superview isKindOfClass:[UIScrollView class]]) {
        superviewWidth = ((UIScrollView *)self.superview).contentSize.width;
    }
    
    [self setFrame:CGRectMake(MAX(kPointingViewHorizontalMargin, MIN(superviewWidth-kPointingViewHorizontalMargin-width, horizontalOffset)), self.point.y, width, kPointingViewArrowHeight+self.titleLabel.frame.size.height+kPointingViewBorderSize*2)];
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:[title uppercaseString]];
    [self.titleLabel sizeToFit];
    [self.titleLabel setFrame:CGRectMake(kPointingViewBorderSize, kPointingViewArrowHeight+kPointingViewBorderSize, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
}

- (void)showInView:(UIView *)view {
    [self setUserInteractionEnabled:YES];
    [view addSubview:self];
    
    [self layoutSubviews];
    [self updateMainViewMask];
}

- (void)tapped {
    if(self.tappedBlock) {
        self.tappedBlock();
    }
}

- (void)updateMainViewMask {
    CGPoint relativePoint = [self convertPoint:self.point fromView:self.superview];
    
    CGFloat rectHeight = self.bounds.size.height-kPointingViewArrowHeight;
    
    UIBezierPath *mask = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, kPointingViewArrowHeight, self.bounds.size.width, rectHeight) cornerRadius:kPointingViewCornerRadius];
    [mask moveToPoint:CGPointMake(relativePoint.x, 0)];
    [mask addLineToPoint:CGPointMake(relativePoint.x+kPointingViewArrowWidth/2, kPointingViewArrowHeight)];
    [mask addLineToPoint:CGPointMake(relativePoint.x+kPointingViewArrowWidth/2, kPointingViewArrowHeight+rectHeight/2)];
    [mask addLineToPoint:CGPointMake(relativePoint.x-kPointingViewArrowWidth/2, kPointingViewArrowHeight+rectHeight/2)];
    [mask addLineToPoint:CGPointMake(relativePoint.x-kPointingViewArrowWidth/2, kPointingViewArrowHeight)];
    [mask closePath];
    [self.shapeLayer setPath:mask.CGPath];
}

@end
