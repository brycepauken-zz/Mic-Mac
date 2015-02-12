//
//  MCActivityIndicator.m
//  micmac
//
//  Created by Bryce Pauken on 2/6/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCActivityIndicatorView.h"

@interface MCActivityIndicatorView()

@property (nonatomic, strong) UIView *circlesOverlay;
@property (nonatomic, strong) CAShapeLayer *circlesOverlayMask;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSRunLoop *displayLinkRunLoop;
@property (nonatomic) CFTimeInterval displayLinkTimestamp;

@end

@implementation MCActivityIndicatorView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 80, 50)];
    if(self) {
        _circlesOverlayMask = [[CAShapeLayer alloc] init];
        [_circlesOverlayMask setFrame:self.bounds];
        
        _circlesOverlay = [[UIView alloc] initWithFrame:self.bounds];
        [_circlesOverlay setBackgroundColor:[UIColor MCOffWhiteColor]];
        [_circlesOverlay.layer setMask:_circlesOverlayMask];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCalled)];
        [_displayLink setFrameInterval:1];
        
        [self setAlpha:0];
        [self addSubview:_circlesOverlay];
        [self startAnimatingWithFadeIn:NO];
    }
    return self;
}

- (void)displayLinkCalled {
    if(!self.displayLinkTimestamp) {
        self.displayLinkTimestamp = self.displayLink.timestamp;
    }
    CFTimeInterval elapsedTime = self.displayLink.timestamp-self.displayLinkTimestamp;
    elapsedTime = elapsedTime - trunc(elapsedTime);
    
    static CGFloat addRadius = 16;
    static CGFloat gravity = -5;
    static CGFloat minRadius = 8;
    static CGFloat upwardVelocity = 1.5;
    
    CGFloat t1 = elapsedTime;
    CGFloat t2 = elapsedTime-0.15;
    CGFloat t3 = elapsedTime-0.30;
    CGFloat x1 = MAX(0,upwardVelocity*t1 + 0.5*gravity*t1*t1);
    CGFloat x2 = MAX(0,upwardVelocity*t2 + 0.5*gravity*t2*t2);
    CGFloat x3 = MAX(0,upwardVelocity*t3 + 0.5*gravity*t3*t3);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, NULL, [[self class] pathForCircleWithRadius:minRadius+x1*addRadius center:CGPointMake(self.bounds.size.width*0.18, self.bounds.size.height/2-x1)].CGPath);
    CGPathAddPath(path, NULL, [[self class] pathForCircleWithRadius:minRadius+x2*addRadius center:CGPointMake(self.bounds.size.width*0.50, self.bounds.size.height/2-x2)].CGPath);
    CGPathAddPath(path, NULL, [[self class] pathForCircleWithRadius:minRadius+x3*addRadius center:CGPointMake(self.bounds.size.width*0.82, self.bounds.size.height/2-x3)].CGPath);
    [self.circlesOverlayMask setPath:path];
}

+ (UIBezierPath *)pathForCircleWithRadius:(CGFloat)radius center:(CGPoint)center {
    return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
}

- (void)startAnimatingWithFadeIn:(BOOL)fadeIn {
    if(!self.displayLinkRunLoop) {
        self.displayLinkTimestamp = 0;
        self.displayLinkRunLoop = [NSRunLoop currentRunLoop];
        [self.displayLink addToRunLoop:self.displayLinkRunLoop forMode:NSRunLoopCommonModes];
        
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)];
        [UIView animateWithDuration:(fadeIn?0.2:0) animations:^{
            [self setAlpha:1];
            [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
        }];
    }
}

- (void)stopAnimating {
    if(self.displayLinkRunLoop) {
        [UIView animateWithDuration:0.2 animations:^{
            [self setAlpha:0];
            [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)];
        } completion:^(BOOL finished){
            [self.displayLink removeFromRunLoop:self.displayLinkRunLoop forMode:NSRunLoopCommonModes];
            self.displayLinkRunLoop = nil;
        }];
    }
}

@end
