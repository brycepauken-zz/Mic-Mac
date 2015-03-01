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

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic) CGFloat contentViewHeight;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) CFTimeInterval displayLinkTimestamp;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) CAShapeLayer *mainViewBorder;
@property (nonatomic) CGFloat mainViewProgress;
@property (nonatomic) CGPoint point;
@property (nonatomic, strong) UIView *windowOverlay;

@end

@implementation MCPointingView

static const int kPointingViewArrowHeight = 12;
static const int kPointingViewArrowWidth = 30;
static const int kPointingViewBorderThickness = 1;
static const int kPointingViewBorderSize = 10;
static const int kPointingViewContentViewWidth = 260;
static const int kPointingViewCornerRadius = 8;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _point = CGPointMake(80, 80);
        
        _mainView = [[UIView alloc] init];
        
        _mainViewBorder = [[CAShapeLayer alloc] init];
        [_mainViewBorder setFillColor:[UIColor MCMainColor].CGColor];
        [_mainViewBorder setLineWidth:kPointingViewBorderThickness];
        [_mainViewBorder setStrokeColor:[UIColor MCMoreOffWhiteColor].CGColor];
        [_mainView.layer insertSublayer:_mainViewBorder atIndex:0];
        
        _contentViewHeight = frame.size.height;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kPointingViewContentViewWidth, _contentViewHeight)];
        [_contentView.layer setAnchorPoint:CGPointMake(0.5, 0)];
        [_contentView setBackgroundColor:[UIColor MCMainColor]];
        [_mainView addSubview:_contentView];
        
        _windowOverlay = [[UIView alloc] init];
        [_windowOverlay setAlpha:0];
        [_windowOverlay setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [_windowOverlay setBackgroundColor:[UIColor blackColor]];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCalled)];
        [_displayLink setFrameInterval:1];
        [_displayLink setPaused:YES];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        [self setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        
        [self addSubview:_windowOverlay];
        [self addSubview:_mainView];
    }
    return self;
}

+ (CGFloat)contentViewWidth {
    return kPointingViewContentViewWidth;
}

- (void)displayLinkCalled {
    if(!self.displayLinkTimestamp) {
        self.displayLinkTimestamp = self.displayLink.timestamp;
    }
    CFTimeInterval progress = MAX(0,MIN(1,(self.displayLink.timestamp-self.displayLinkTimestamp)/0.3))*2;
    if(progress==2) {
        [self.displayLink setPaused:YES];
    }
    if(progress<1) {
        progress = progress*progress*progress;
    }
    else {
        progress -= 2;
        progress = (progress*progress*progress)+2;
    }
    [self setMainViewProgress:progress/2];
    
    [self updateMainViewMask];
}

- (void)layoutSubviews {
    [self.mainView setFrame:CGRectMake((self.bounds.size.width-kPointingViewContentViewWidth)/2-kPointingViewBorderSize, self.point.y, kPointingViewContentViewWidth+kPointingViewBorderSize*2, kPointingViewArrowHeight+self.contentViewHeight+kPointingViewBorderSize*2)];
    
}

- (void)show {
    UIView *appMainView = [MCCommon mainView];
    [self setFrame:appMainView.bounds];
    
    [self.contentView setFrame:CGRectMake(kPointingViewBorderSize, kPointingViewArrowHeight+kPointingViewBorderSize, kPointingViewContentViewWidth, self.contentViewHeight)];
    [self.contentView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 0)];
    
    [self.windowOverlay setAlpha:0.5];
    [self.windowOverlay setFrame:self.bounds];
    [appMainView addSubview:self];
    
    [self setMainViewProgress:0];
    [self.displayLink setPaused:NO];
    
    [self setNeedsLayout];
}

- (void)updateMainViewMask {
    CGFloat totalHeight = self.mainView.bounds.size.height*self.mainViewProgress;
    CGPoint relativePoint = [self convertPoint:self.point toView:self.mainView];
    
    CGFloat arrowHeight = MIN(totalHeight, kPointingViewArrowHeight);
    CGFloat rectHeight = MAX(0, totalHeight-kPointingViewArrowHeight);
    CGFloat contentViewScale = MAX(0, MIN(self.contentViewHeight, totalHeight-kPointingViewArrowHeight-kPointingViewBorderSize*2))/self.contentViewHeight;
    
    //just draw arrow
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
    }
    
    
    //UIBezierPath *mask = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, kPointingViewArrowHeight, self.mainView.bounds.size.width, rectHeight) cornerRadius:kPointingViewCornerRadius];
    //[mask appendPath:arrow];
    
    
    
    [self.contentView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, contentViewScale)];
}

@end
