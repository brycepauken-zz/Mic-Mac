//
//  MCVoteView.m
//  micmac
//
//  Created by Bryce Pauken on 2/21/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCVoteView.h"

@interface MCVoteView()

@property (nonatomic, strong) UIButton *bottomButton;
@property (nonatomic, strong) UILabel *pointLabel;
@property (nonatomic) NSInteger points;
@property (nonatomic, strong) UIButton *topButton;

@end

@implementation MCVoteView

static const int kPointFontSize = 20;
static const int kPointLabelVerticalMargin = 2;
static const int kVoteArrowHeight = 10;
static const int kVoteArrowThickness = 2;
static const int kVoteArrowWidth = 22;

- (instancetype)initAndSize {
    self = [self initWithFrame:CGRectZero];
    if(self) {
        [self sizeToFit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _bottomButton = [[self class] voteArrowPointingUp:NO];
        _topButton = [[self class] voteArrowPointingUp:YES];
        
        _points = 0;
        
        _pointLabel = [[UILabel alloc] init];
        [_pointLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:kPointFontSize]];
        [_pointLabel setText:@"0"];
        [_pointLabel setTextColor:[UIColor darkGrayColor]];
        
        [self addSubview:_bottomButton];
        [self addSubview:_topButton];
        [self addSubview:_pointLabel];
        
        [self repositionSubviews];
    }
    return self;
}

- (void)repositionSubviews {
    [self.pointLabel sizeToFit];
    CGFloat height = self.pointLabel.frame.size.height+kPointLabelVerticalMargin*2+kVoteArrowHeight*2;
    CGFloat width = MAX(self.pointLabel.frame.size.width, kVoteArrowWidth);
    
    [self.topButton setFrame:CGRectMake(width-kVoteArrowWidth, 0, kVoteArrowWidth, kVoteArrowHeight)];
    [self.bottomButton setFrame:CGRectMake(width-kVoteArrowWidth, height-kVoteArrowHeight, kVoteArrowWidth, kVoteArrowHeight)];
    [self.pointLabel setCenter:CGPointMake(width/2, height/2)];
}

- (void)setPoints:(NSInteger)points {
    _points = points;
    [self.pointLabel setText:[NSString stringWithFormat:@"%li",points]];
    [self repositionSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.topButton.frame.origin.x+self.topButton.frame.size.width, self.bottomButton.frame.origin.y+self.bottomButton.frame.size.height);
}

+ (CGFloat)widthForViewWithPoints:(NSInteger)points {
    static UIFont *pointFont;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointFont = [UIFont fontWithName:@"AvenirNext-Regular" size:kPointFontSize];
    });
    CGSize pointSize = [[NSString stringWithFormat:@"%li",points] sizeWithFont:pointFont constrainedToWidth:CGFLOAT_MAX];
    return MAX(pointSize.width, kVoteArrowWidth);
}

+ (UIButton *)voteArrowPointingUp:(BOOL)pointingUp {
    static CGFloat (^verticalOffset)(CGFloat y, BOOL pointingUp) = ^CGFloat(CGFloat y, BOOL pointingUp) {
        return (pointingUp?y:(kVoteArrowHeight-y));
    };
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kVoteArrowWidth, kVoteArrowHeight)];
    [button setBackgroundColor:[UIColor darkGrayColor]];
    
    UIBezierPath *buttonMaskPath = [UIBezierPath bezierPath];
    [buttonMaskPath moveToPoint:CGPointMake(kVoteArrowWidth/2, verticalOffset(0, pointingUp))];
    [buttonMaskPath addLineToPoint:CGPointMake(0, verticalOffset(kVoteArrowHeight-kVoteArrowThickness, pointingUp))];
    [buttonMaskPath addLineToPoint:CGPointMake(0, verticalOffset(kVoteArrowHeight, pointingUp))];
    [buttonMaskPath addLineToPoint:CGPointMake(kVoteArrowWidth/2, verticalOffset(kVoteArrowThickness, pointingUp))];
    [buttonMaskPath addLineToPoint:CGPointMake(kVoteArrowWidth, verticalOffset(kVoteArrowHeight, pointingUp))];
    [buttonMaskPath addLineToPoint:CGPointMake(kVoteArrowWidth, verticalOffset(kVoteArrowHeight-kVoteArrowThickness, pointingUp))];
    [buttonMaskPath closePath];
    
    CAShapeLayer *buttonMask = [[CAShapeLayer alloc] init];
    [buttonMask setPath:buttonMaskPath.CGPath];
    [button.layer setMask:buttonMask];
    
    return button;
}

@end
