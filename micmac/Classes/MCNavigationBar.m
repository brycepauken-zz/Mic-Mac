//
//  MCNavigationBar.m
//  micmac
//
//  Created by Bryce Pauken on 2/1/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCNavigationBar.h"

@interface MCNavigationBar()

@property (nonatomic, strong) UIView *bottomOverlay;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, copy) void (^rightButtonTapped)();
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MCNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_rightButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setHidden:YES];
        [self addSubview:_rightButton];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/4, 20, self.bounds.size.width/2, self.bounds.size.height-20)];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [_titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor MCOffWhiteColor]];
        
        _bottomOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 10)];
        [_bottomOverlay setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [_bottomOverlay setBackgroundColor:[UIColor MCMainColor]];
        
        [self setBackgroundColor:[UIColor MCMainColor]];
        
        [self addSubview:_titleLabel];
        [self addSubview:_bottomOverlay];
        
        [self setFrame:self.frame];
    }
    return  self;
}

- (void)buttonTapped:(UIButton *)sender {
    if(sender == self.rightButton && self.rightButtonTapped) {
        self.rightButtonTapped();
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(CGRectContainsPoint(CGRectInset(self.rightButton.frame, -20, -20), point)) {
        return self.rightButton;
    }
    return [super hitTest:point withEvent:event];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat buttonMargin = ((self.bounds.size.height-20)-self.rightButton.bounds.size.height)/2;
    [self.rightButton setFrame:CGRectMake(self.bounds.size.width-self.rightButton.bounds.size.width-buttonMargin, buttonMargin+20, self.rightButton.bounds.size.width, self.rightButton.bounds.size.height)];
    
    [self updateBottomOverlayMask];
}

- (void)setRightButtonImage:(UIImage *)image {
    if(image) {
        CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, image.scale);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [image drawInRect:imageRect];
        CGContextSetFillColorWithColor(ctx, [UIColor MCOffWhiteColor].CGColor);
        
        CGContextSetBlendMode(ctx, kCGBlendModeSourceAtop);
        CGContextFillRect(ctx, imageRect);
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.rightButton setImage:result forState:UIControlStateNormal];
    }
    [self.rightButton setHidden:!image];
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

- (void)updateBottomOverlayMask {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, self.bottomOverlay.bounds.size.height)];
    [path addCurveToPoint:CGPointMake(self.bottomOverlay.bounds.size.width*0.25, 0) controlPoint1:CGPointMake(0, 0) controlPoint2:CGPointMake(self.bottomOverlay.bounds.size.width*0.125, 0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width*0.75, 0)];
    [path addCurveToPoint:CGPointMake(self.bottomOverlay.bounds.size.width, self.bottomOverlay.bounds.size.height) controlPoint1:CGPointMake(self.bottomOverlay.bounds.size.width*0.875, 0) controlPoint2:CGPointMake(self.bottomOverlay.bounds.size.width, 0)];
    [path addLineToPoint:CGPointMake(self.bottomOverlay.bounds.size.width, 0)];
    [path closePath];
    
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    [mask setPath:path.CGPath];
    [self.bottomOverlay.layer setMask:mask];
}

@end
