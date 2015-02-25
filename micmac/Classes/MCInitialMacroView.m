//
//  MCInitialMacroView.m
//  micmac
//
//  Created by Bryce Pauken on 2/23/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCInitialMacroView.h"

#import "MCActivityIndicatorView.h"
#import "MCAPIHandler.h"
#import "MCButton.h"
#import "MCGroupSelectionView.h"

@interface MCInitialMacroView()

@property (nonatomic, strong) MCActivityIndicatorView *activityIndicatorView;
@property (nonatomic) BOOL activityIndicatorShouldHide;
@property (nonatomic, copy) void (^completionBlock)(NSArray *groups);
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) MCButton *continueButton;
@property (nonatomic, strong) MCGroupSelectionView *groupSelectionView;
@property (nonatomic, strong) UIView *sideFadeLeft;
@property (nonatomic, strong) UIView *sideFadeRight;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *topicsString;
@property (nonatomic, strong) NSString *topicsStringSuffix;

@end

@implementation MCInitialMacroView

static const int kContentViewCornerRadius = 10;
static const int kContentViewMargin = 20;
static const int kLabelVerticalMargins = 10;
static const int kSideFadeWidth = 10;
static const int kSubtitleFontSize = 15;
NSString *kSubtitleMultilineText = @"Select %@ that\ninterest%@ you to get started.";
NSString *kSubtitleText = @"Select %@ that interest%@ you to get started.";
static const int kTitleFontSize = 24;
static NSString *kTitleText = @"Just One More Step";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        __weak MCInitialMacroView *weakSelf = self;
        
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
        
        _topicsString = @"a few topics";
        _topicsStringSuffix = @"";
        _subtitleLabel = [[UILabel alloc] init];
        [_subtitleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:kSubtitleFontSize]];
        [_subtitleLabel setNumberOfLines:0];
        [_subtitleLabel setText:[NSString stringWithFormat:kSubtitleMultilineText, _topicsString, _topicsStringSuffix]];
        [_subtitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_subtitleLabel setTextColor:[UIColor MCOffWhiteColor]];
        [_subtitleLabel sizeToFit];
        [_subtitleLabel setCenter:CGPointMake(self.bounds.size.width/2, 40)];
        [_contentView addSubview:_subtitleLabel];
        
        _continueButton = [[MCButton alloc] initWithFrame:CGRectMake(0, 0, 180, 36)];
        [_continueButton addTarget:self action:@selector(contineButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_continueButton setHidden:YES];
        [_continueButton setTitle:@"Continue"];
        [_continueButton setTitleSize:18];
        [_contentView addSubview:_continueButton];
        
        _groupSelectionView = [[MCGroupSelectionView alloc] init];
        [_groupSelectionView setAlpha:0];
        [_groupSelectionView setSelectionChanged:^{
            [weakSelf groupSelectionChanged];
        }];
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

- (void)contineButtonTapped {
    [self setUserInteractionEnabled:NO];
    [self.groupSelectionView setTransform:CGAffineTransformMakeScale(1, 1)];
    [UIView animateWithDuration:0.25 delay:0.1 options:0 animations:^{
        [self.continueButton setAlpha:0];
        [self.groupSelectionView setAlpha:0];
        [self.groupSelectionView setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.activityIndicatorView startAnimatingWithFadeIn:YES];
        });
    } completion:nil];
    
    NSMutableString *groupsString = [[NSMutableString alloc] init];
    for(int i=0;i<self.groupSelectionView.selectedIndexes.count;i++) {
        [groupsString appendFormat:@"%@%@",(i==0?@"":@","),[[[self.groupSelectionView groups] objectAtIndex:[[self.groupSelectionView.selectedIndexes objectAtIndex:i] integerValue]] objectForKey:@"id"]];
    }
    [MCAPIHandler makeRequestToFunction:@"Follow" components:nil parameters:@{@"groups":groupsString} completion:^(NSDictionary *data) {
        if(data && self.completionBlock) {
            self.completionBlock([[self.groupSelectionView groups] objectsAtIndexes:[[self.groupSelectionView groups] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [self.groupSelectionView.selectedIndexes containsObject:@(idx)];
            }]]);
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView setFrame:CGRectInset(self.bounds, kContentViewMargin, kContentViewMargin)];
    
    CGSize singleLineLabelSize = [[NSString stringWithFormat:kSubtitleText, _topicsString, _topicsStringSuffix] sizeWithFont:self.subtitleLabel.font constrainedToWidth:CGFLOAT_MAX];
    CGSize multilineLabelSize = [[NSString stringWithFormat:kSubtitleMultilineText, _topicsString, _topicsStringSuffix] sizeWithFont:self.subtitleLabel.font constrainedToWidth:CGFLOAT_MAX];
    [self.subtitleLabel setFrame:CGRectMake(self.subtitleLabel.frame.origin.x, self.subtitleLabel.frame.origin.y, singleLineLabelSize.width, multilineLabelSize.height)];
    if(singleLineLabelSize.width<self.contentView.bounds.size.width-20) {
        [self.subtitleLabel setText:[NSString stringWithFormat:kSubtitleText, _topicsString, _topicsStringSuffix]];
    }
    else {
        [self.subtitleLabel setText:[NSString stringWithFormat:kSubtitleMultilineText, _topicsString, _topicsStringSuffix]];
    }
    [self.subtitleLabel sizeToFit];
    
    [self.titleLabel setFrame:CGRectMake((self.contentView.bounds.size.width-self.titleLabel.frame.size.width)/2, kLabelVerticalMargins+kContentViewCornerRadius/2, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
    [self.subtitleLabel setFrame:CGRectMake((self.contentView.bounds.size.width-self.subtitleLabel.frame.size.width)/2, kLabelVerticalMargins*2+self.titleLabel.frame.size.height, self.subtitleLabel.frame.size.width, self.subtitleLabel.frame.size.height)];
    [self.continueButton setCenter:CGPointMake(self.subtitleLabel.center.x, self.subtitleLabel.center.y+2)];
    CGFloat bottomSubtitleOffset = self.subtitleLabel.frame.origin.y+self.subtitleLabel.frame.size.height;
    [self.activityIndicatorView setCenter:CGPointMake(self.contentView.bounds.size.width/2, bottomSubtitleOffset+(self.contentView.bounds.size.height-bottomSubtitleOffset)/2-8)];
    [self.groupSelectionView setFrame:CGRectMake(0, bottomSubtitleOffset+kLabelVerticalMargins, self.contentView.bounds.size.width, self.contentView.bounds.size.height-(bottomSubtitleOffset+kLabelVerticalMargins+kContentViewCornerRadius))];
}

- (void)groupSelectionChanged {
    BOOL showContinueButton = YES;
    if(self.groupSelectionView.selectedIndexes.count<4) {
        showContinueButton = NO;
        switch (self.groupSelectionView.selectedIndexes.count) {
            case 1:
                [self setTopicsString:@"three more topics"];
                [self setTopicsStringSuffix:@""];
                break;
            case 2:
                [self setTopicsString:@"two more topics"];
                [self setTopicsStringSuffix:@""];
                break;
            case 3:
                [self setTopicsString:@"one more topic"];
                [self setTopicsStringSuffix:@"s"];
                break;
            default:
                [self setTopicsString:@"a few topics"];
                [self setTopicsStringSuffix:@""];
                break;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.continueButton setHidden:!showContinueButton];
        [self.subtitleLabel setHidden:showContinueButton];
    }];
    if(!showContinueButton) {
        CATransition *textAnimation = [CATransition animation];
        [textAnimation setDuration:0.1];
        [textAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [textAnimation setType:kCATransitionFade];
        [self.subtitleLabel.layer addAnimation:textAnimation forKey:@"kCATransitionFade"];
        [self layoutSubviews];
    }
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
