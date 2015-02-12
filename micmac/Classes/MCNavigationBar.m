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
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MCNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/4, 20, self.bounds.size.width/2, self.bounds.size.height-20)];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [_titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor MCOffWhiteColor]];
        
        _bottomOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 8)];
        [_bottomOverlay setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [_bottomOverlay setBackgroundColor:[UIColor MCMainColor]];
        [self updateBottomOverlayMask];
        
        [self setBackgroundColor:[UIColor MCMainColor]];
        
        [self addSubview:_titleLabel];
        [self addSubview:_bottomOverlay];
    }
    return  self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self updateBottomOverlayMask];
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

- (void)updateBottomOverlayMask {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, self.bottomOverlay.bounds.size.height)];
    [path addCurveToPoint:CGPointMake(self.bottomOverlay.bounds.size.width*0.5, 0) controlPoint1:CGPointMake(0, 0) controlPoint2:CGPointMake(self.bottomOverlay.bounds.size.width*0.25, 0)];
    [path addCurveToPoint:CGPointMake(self.bottomOverlay.bounds.size.width, self.bottomOverlay.bounds.size.height) controlPoint1:CGPointMake(self.bottomOverlay.bounds.size.width*0.75, 0) controlPoint2:CGPointMake(self.bottomOverlay.bounds.size.width, 0)];
    [path addLineToPoint:CGPointMake(self.bottomOverlay.bounds.size.width, 0)];
    [path closePath];
    
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    [mask setPath:path.CGPath];
    [self.bottomOverlay.layer setMask:mask];
}

@end
