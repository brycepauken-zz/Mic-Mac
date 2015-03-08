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
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MCPointingView

static const int kPointingViewArrowHeight = 8;
static const int kPointingViewArrowWidth = 16;
static const int kPointingViewBorderSize = 8;
static const int kPointingViewCornerRadius = 4;
static const int kPointingViewFontSize = 16;
static const int kPointingViewHorizontalMargin = 10;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        [_shapeLayer setFillColor:[UIColor MCOffWhiteColor].CGColor];
        [_shapeLayer setShadowColor:[UIColor MCOffBlackColor].CGColor];
        [_shapeLayer setShadowOffset:CGSizeMake(0, -1)];
        [_shapeLayer setShadowOpacity:0.4];
        [_shapeLayer setShadowRadius:1];
        [self.layer insertSublayer:_shapeLayer atIndex:0];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setBackgroundColor:[UIColor MCOffWhiteColor]];
        [_titleLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:kPointingViewFontSize]];
        [_titleLabel setTextColor:[UIColor MCOffBlackColor]];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)dismiss {
    [self setUserInteractionEnabled:NO];
    [self removeFromSuperview];
}

- (void)layoutSubviews {
    [self setFrame:CGRectMake(MAX(kPointingViewHorizontalMargin, self.point.x-self.titleLabel.frame.size.width/2-kPointingViewBorderSize), self.point.y, self.titleLabel.frame.size.width+kPointingViewBorderSize*2, kPointingViewArrowHeight+self.titleLabel.frame.size.height+kPointingViewBorderSize*2)];
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
    [self.titleLabel sizeToFit];
    [self.titleLabel setFrame:CGRectMake(kPointingViewBorderSize, kPointingViewArrowHeight+kPointingViewBorderSize, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
}

- (void)showInView:(UIView *)view {
    [self setUserInteractionEnabled:YES];
    [view addSubview:self];
    
    [self layoutSubviews];
    [self updateMainViewMask];
}

- (void)updateMainViewMask {
    CGPoint relativePoint = [self convertPoint:self.point toView:self];
    
    CGFloat rectHeight = self.bounds.size.height-kPointingViewArrowHeight;
    
    /*//just draw arrow
    if(arrowHeight < kPointingViewArrowHeight) {
        UIBezierPath *mask = [UIBezierPath bezierPath];
        [mask moveToPoint:CGPointMake(relativePoint.x, 0)];
        [mask addLineToPoint:CGPointMake(relativePoint.x+kPointingViewArrowWidth/2, arrowHeight)];
        [mask addLineToPoint:CGPointMake(relativePoint.x-kPointingViewArrowWidth/2, arrowHeight)];
        [mask closePath];
        [self.mainViewBorder setPath:mask.CGPath];
    }
    //draw arrow and box
    else {
        UIBezierPath *mask = [UIBezierPath bezierPath];
        [mask moveToPoint:CGPointMake(relativePoint.x, 0)];
        [mask addLineToPoint:CGPointMake(relativePoint.x+kPointingViewArrowWidth/2, kPointingViewArrowHeight)];
        [mask addLineToPoint:CGPointMake(self.mainView.bounds.size.width-kPointingViewCornerRadius, kPointingViewArrowHeight)];
        [mask addArcWithCenter:CGPointMake(self.mainView.bounds.size.width-kPointingViewCornerRadius, kPointingViewArrowHeight+kPointingViewCornerRadius) radius:kPointingViewCornerRadius startAngle:M_PI*1.5 endAngle:M_PI*2 clockwise:YES];
        [mask addLineToPoint:CGPointMake(self.mainView.bounds.size.width, kPointingViewArrowHeight+rectHeight-kPointingViewCornerRadius)];
        [mask addArcWithCenter:CGPointMake(self.mainView.bounds.size.width-kPointingViewCornerRadius, kPointingViewArrowHeight+rectHeight-kPointingViewCornerRadius) radius:kPointingViewCornerRadius startAngle:0 endAngle:M_PI*0.5 clockwise:YES];
        [mask addLineToPoint:CGPointMake(kPointingViewCornerRadius, kPointingViewArrowHeight+rectHeight)];
        [mask addArcWithCenter:CGPointMake(kPointingViewCornerRadius, kPointingViewArrowHeight+rectHeight-kPointingViewCornerRadius) radius:kPointingViewCornerRadius startAngle:M_PI*0.5 endAngle:M_PI clockwise:YES];
        [mask addLineToPoint:CGPointMake(0, kPointingViewArrowHeight+kPointingViewCornerRadius)];
        [mask addArcWithCenter:CGPointMake(kPointingViewCornerRadius, kPointingViewArrowHeight+kPointingViewCornerRadius) radius:kPointingViewCornerRadius startAngle:M_PI endAngle:M_PI*1.5 clockwise:YES];
        [mask addLineToPoint:CGPointMake(relativePoint.x-kPointingViewArrowWidth/2, arrowHeight)];
        [mask closePath];
        [self.mainViewBorder setPath:mask.CGPath];
    }*/
    
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
