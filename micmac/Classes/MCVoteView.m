//
//  MCVoteView.m
//  micmac
//
//  Created by Bryce Pauken on 2/21/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCVoteView.h"

@interface MCVoteView()

@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic) NSInteger points;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIView *surroundingCircle;
@property (nonatomic) CGFloat surroundingCircleScaleFactor;

@end

@implementation MCVoteView

static const float kCircleThickness = 1.5;
static const int kPointsAdditionalSpace = 2;
static const int kPointsMaxFontSize = 24;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _surroundingCircleScaleFactor = 1;
        _surroundingCircle = [[UIView alloc] initWithFrame:self.bounds];
        [_surroundingCircle setBackgroundColor:[UIColor grayColor]];
        
        _pointsLabel = [[UILabel alloc] init];
        [_pointsLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:kPointsMaxFontSize]];
        [_pointsLabel setTextColor:[UIColor grayColor]];
        
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [_tapRecognizer setDelegate:self];
        [self addGestureRecognizer:_tapRecognizer];
        
        [self setPoints:0];
        [self updateSurroundingCircleMask];
        
        [self addSubview:_surroundingCircle];
        [self addSubview:_pointsLabel];
    }
    return self;
}

- (void)setPoints:(NSInteger)points {
    _points = points;
    
    int fontSize = kPointsMaxFontSize;
    CGFloat innerRadius = MIN(self.bounds.size.width, self.bounds.size.height)/2-kCircleThickness+kPointsAdditionalSpace;
    innerRadius *= innerRadius;
    NSString *pointsText = [NSString stringWithFormat:@"%li",points];
    while(fontSize>0) {
        CGSize pointsSize = [pointsText sizeWithFont:[UIFont fontWithName:@"AvenirNext-Regular" size:fontSize] constrainedToWidth:CGFLOAT_MAX];
        pointsSize.width/=2;
        pointsSize.height/=2;
        if(pointsSize.width*pointsSize.width+pointsSize.height*pointsSize.height<=innerRadius) {
            break;
        }
        else {
            fontSize--;
        }
    }
    [self.pointsLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:fontSize]];
    [self.pointsLabel setText:pointsText];
    [self.pointsLabel sizeToFit];
    [self.pointsLabel setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
}

- (void)tapped {
    self.points++;
    [self.pointsLabel setTextColor:[UIColor MCOffBlackColor]];
    [self.surroundingCircle setBackgroundColor:[UIColor MCOffBlackColor]];
}

- (void)updateSurroundingCircleMask {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat minDimension = MIN(self.bounds.size.width, self.bounds.size.height)/2;
    CGFloat outerRadius = minDimension*self.surroundingCircleScaleFactor;
    CGFloat innerRadius = MAX(0, (minDimension-kCircleThickness)*self.surroundingCircleScaleFactor);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithArcCenter:center radius:outerRadius startAngle:0 endAngle:M_PI*2 clockwise:NO];
    [maskPath appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:innerRadius startAngle:0 endAngle:M_PI*2 clockwise:NO]];
    
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setPath:maskPath.CGPath];
    [mask setContentsScale:[UIScreen mainScreen].scale];
    
    [self.surroundingCircle.layer setMask:mask];
}

@end
