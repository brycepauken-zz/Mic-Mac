//
//  MCVoteView.m
//  micmac
//
//  Created by Bryce Pauken on 2/21/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCVoteView.h"

@interface MCVoteView()

@property (nonatomic) CGFloat circleThickness;
@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic, strong) NSString *pointsLabelFontName;
@property (nonatomic) NSInteger points;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIView *surroundingCircle;
@property (nonatomic) CGFloat surroundingCircleScaleFactor;
@property (nonatomic, copy) void (^voteChangedBlock)(MCVoteViewState state);
@property (nonatomic) MCVoteViewState voteState;

@end

@implementation MCVoteView

static const float kCircleInitialThickness = 1.5;
static const int kPointsAdditionalSpace = 2;
static const int kPointsMaxFontSize = 16;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _circleThickness = kCircleInitialThickness;
        _pointsLabelFontName = @"AvenirNext-Regular";
        _surroundingCircleScaleFactor = 1;
        _voteState = MCVoteViewStateDefault;
        
        _surroundingCircle = [[UIView alloc] initWithFrame:self.bounds];
        [_surroundingCircle setBackgroundColor:[UIColor grayColor]];
        
        _pointsLabel = [[UILabel alloc] init];
        [_pointsLabel setFont:[UIFont fontWithName:_pointsLabelFontName size:kPointsMaxFontSize]];
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
    CGFloat innerRadius = MIN(self.bounds.size.width, self.bounds.size.height)/2-self.circleThickness+kPointsAdditionalSpace;
    innerRadius *= innerRadius;
    NSString *pointsText = [NSString stringWithFormat:@"%li",points];
    while(fontSize>0) {
        CGSize pointsSize = [pointsText sizeWithFont:[UIFont fontWithName:_pointsLabelFontName size:fontSize] constrainedToWidth:CGFLOAT_MAX];
        pointsSize.width/=2;
        pointsSize.height/=2;
        if(pointsSize.width*pointsSize.width+pointsSize.height*pointsSize.height<=innerRadius) {
            break;
        }
        else {
            fontSize--;
        }
    }
    [self.pointsLabel setFont:[UIFont fontWithName:_pointsLabelFontName size:fontSize]];
    [self.pointsLabel setText:pointsText];
    [self.pointsLabel sizeToFit];
    [self.pointsLabel setCenter:CGPointMake(self.bounds.size.width/2+0.25, self.bounds.size.height/2+0.25)];
}

- (void)tapped {
    if(self.voteState == MCVoteViewStateDefault) {
        [self setVoteState:MCVoteViewStateUpVoted];
        [self setPointsLabelFontName:@"AvenirNext-DemiBold"];
        self.points++;
        [self.pointsLabel setTextColor:[UIColor MCMainColor]];
        [self.surroundingCircle setBackgroundColor:[UIColor MCMainColor]];
        [self setCircleThickness:kCircleInitialThickness*1.25];
    }
    else {
        [self setVoteState:MCVoteViewStateDefault];
        [self setPointsLabelFontName:@"AvenirNext-Regular"];
        self.points--;
        [self.pointsLabel setTextColor:[UIColor grayColor]];
        [self.surroundingCircle setBackgroundColor:[UIColor grayColor]];
        [self setCircleThickness:kCircleInitialThickness];
    }
    if(self.voteChangedBlock) {
        self.voteChangedBlock(self.voteState);
    }
    [self updateSurroundingCircleMask];
}

- (void)updateSurroundingCircleMask {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat minDimension = MIN(self.bounds.size.width, self.bounds.size.height)/2;
    CGFloat outerRadius = minDimension*self.surroundingCircleScaleFactor;
    CGFloat innerRadius = MAX(0, (minDimension-self.circleThickness)*self.surroundingCircleScaleFactor);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithArcCenter:center radius:outerRadius startAngle:0 endAngle:M_PI*2 clockwise:NO];
    [maskPath appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:innerRadius startAngle:0 endAngle:M_PI*2 clockwise:NO]];
    
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    [mask setContentsScale:[UIScreen mainScreen].scale];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setPath:maskPath.CGPath];
    
    [self.surroundingCircle.layer setMask:mask];
}

@end
