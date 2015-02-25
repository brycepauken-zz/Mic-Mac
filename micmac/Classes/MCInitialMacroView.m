//
//  MCInitialMacroView.m
//  micmac
//
//  Created by Bryce Pauken on 2/23/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCInitialMacroView.h"

#import "MCActivityIndicatorView.h"
#import "MCGroupSelectionView.h"

@interface MCInitialMacroView()

@property (nonatomic, strong) MCActivityIndicatorView *activityIndicatorView;
@property (nonatomic) BOOL activityIndicatorShouldHide;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) MCGroupSelectionView *groupSelectionView;
@property (nonatomic, strong) UIView *sideFadeLeft;
@property (nonatomic, strong) UIView *sideFadeRight;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MCInitialMacroView

static const int kContentViewCornerRadius = 10;
static const int kContentViewMargin = 20;
static const int kLabelVerticalMargins = 10;
static const int kSideFadeWidth = 10;
static const int kSubtitleFontSize = 15;
static NSString *kSubtitleMultilineText = @"Select a few topics that\ninterest you to get started.";
static NSString *kSubtitleText = @"Select a few topics that interest you to get started.";
static const int kTitleFontSize = 24;
static NSString *kTitleText = @"Just One More Step";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _contentView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, kContentViewMargin, kContentViewMargin)];
        [_contentView setBackgroundColor:[UIColor MCMainColor]];
        [_contentView.layer setCornerRadius:kContentViewCornerRadius];
        [_contentView.layer setMasksToBounds:YES];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:kTitleFontSize]];
        [_titleLabel setText:kTitleText];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor MCOffWhiteColor]];
        [_titleLabel sizeToFit];
        [_contentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        [_subtitleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:kSubtitleFontSize]];
        [_subtitleLabel setNumberOfLines:0];
        [_subtitleLabel setText:kSubtitleMultilineText];
        [_subtitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_subtitleLabel setTextColor:[UIColor MCOffWhiteColor]];
        [_subtitleLabel sizeToFit];
        [_subtitleLabel setCenter:CGPointMake(self.bounds.size.width/2, 40)];
        [_contentView addSubview:_subtitleLabel];
        
        _groupSelectionView = [[MCGroupSelectionView alloc] init];
        [_groupSelectionView setAlpha:0];
        [_contentView addSubview:_groupSelectionView];
        
        _activityIndicatorView = [[MCActivityIndicatorView alloc] init];
        [_contentView addSubview:_activityIndicatorView];
        
        _sideFadeLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSideFadeWidth, _contentView.bounds.size.height)];
        [_sideFadeLeft setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin];
        CAGradientLayer *leftSideGradient = [CAGradientLayer layer];
        [leftSideGradient setColors:@[(id)[UIColor MCMainColor].CGColor, (id)[[UIColor MCMainColor] colorWithAlphaComponent:0].CGColor]];
        [leftSideGradient setEndPoint:CGPointMake(1, 0.5)];
        [leftSideGradient setFrame:_sideFadeLeft.bounds];
        [leftSideGradient setStartPoint:CGPointMake(0, 0.5)];
        [_sideFadeLeft.layer addSublayer:leftSideGradient];
        [_contentView addSubview:_sideFadeLeft];
        
        _sideFadeRight = [[UIView alloc] initWithFrame:CGRectMake(_contentView.bounds.size.width-kSideFadeWidth, 0, kSideFadeWidth, _contentView.bounds.size.height)];
        [_sideFadeRight setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin];
        CAGradientLayer *rightSideGradient = [CAGradientLayer layer];
        [rightSideGradient setColors:@[(id)[UIColor MCMainColor].CGColor, (id)[[UIColor MCMainColor] colorWithAlphaComponent:0].CGColor]];
        [rightSideGradient setEndPoint:CGPointMake(0, 0.5)];
        [rightSideGradient setFrame:_sideFadeRight.bounds];
        [rightSideGradient setStartPoint:CGPointMake(1, 0.5)];
        [_sideFadeRight.layer addSublayer:rightSideGradient];
        [_contentView addSubview:_sideFadeRight];
        
        [self addSubview:_contentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView setFrame:CGRectInset(self.bounds, kContentViewMargin, kContentViewMargin)];
    
    CGSize singleLineLabelSize = [kSubtitleText sizeWithFont:self.subtitleLabel.font constrainedToWidth:CGFLOAT_MAX];
    CGSize multilineLabelSize = [kSubtitleMultilineText sizeWithFont:self.subtitleLabel.font constrainedToWidth:CGFLOAT_MAX];
    [self.subtitleLabel setFrame:CGRectMake(self.subtitleLabel.frame.origin.x, self.subtitleLabel.frame.origin.y, singleLineLabelSize.width, multilineLabelSize.height)];
    if(singleLineLabelSize.width<self.contentView.bounds.size.width-20) {
        [self.subtitleLabel setText:kSubtitleText];
    }
    else {
        [self.subtitleLabel setText:kSubtitleMultilineText];
    }
    [self.subtitleLabel sizeToFit];
    
    [self.titleLabel setFrame:CGRectMake((self.contentView.bounds.size.width-self.titleLabel.frame.size.width)/2, kLabelVerticalMargins+kContentViewCornerRadius/2, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
    [self.subtitleLabel setFrame:CGRectMake((self.contentView.bounds.size.width-self.subtitleLabel.frame.size.width)/2, kLabelVerticalMargins*2+self.titleLabel.frame.size.height, self.subtitleLabel.frame.size.width, self.subtitleLabel.frame.size.height)];
    CGFloat bottomSubtitleOffset = self.subtitleLabel.frame.origin.y+self.subtitleLabel.frame.size.height;
    [self.activityIndicatorView setCenter:CGPointMake(self.contentView.bounds.size.width/2, bottomSubtitleOffset+(self.contentView.bounds.size.height-bottomSubtitleOffset)/2-8)];
    [self.groupSelectionView setFrame:CGRectMake(0, bottomSubtitleOffset+kLabelVerticalMargins, self.contentView.bounds.size.width, self.contentView.bounds.size.height-(bottomSubtitleOffset+kLabelVerticalMargins+kContentViewCornerRadius))];
}

- (void)setGroups:(NSArray *)groups {
    [self.groupSelectionView setGroups:groups];
    [self tryHidingActivityIndicator];
}

- (void)tryHidingActivityIndicator {
    BOOL showGroupSelectionView = NO;
    @synchronized(self) {
        if(self.activityIndicatorShouldHide) {
            [self.activityIndicatorView stopAnimating];
            showGroupSelectionView = YES;
        }
        else {
            [self setActivityIndicatorShouldHide:YES];
        }
    }
    if(showGroupSelectionView) {
        [self.groupSelectionView setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        [UIView animateWithDuration:0.25 delay:0.1 options:0 animations:^{
            [self.groupSelectionView setAlpha:1];
            [self.groupSelectionView setTransform:CGAffineTransformMakeScale(1, 1)];
        } completion:nil];
    }
}

- (void)willShow {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tryHidingActivityIndicator];
    });
}

@end
