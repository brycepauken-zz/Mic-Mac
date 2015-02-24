//
//  MCInitialMacroView.m
//  micmac
//
//  Created by Bryce Pauken on 2/23/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCInitialMacroView.h"

#import "MCActivityIndicatorView.h"

@interface MCInitialMacroView()

@property (nonatomic, strong) MCActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MCInitialMacroView

static const int kContentViewCornerRadius = 10;
static const int kContentViewMargin = 20;
static const int kLabelVerticalMargins = 10;
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
        
        _activityIndicatorView = [[MCActivityIndicatorView alloc] init];
        [_contentView addSubview:_activityIndicatorView];
        
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
}

- (void)setGroups:(NSArray *)groups {
    _groups = groups;
    if(groups && ![groups isEqual:[NSNull null]] && groups.count) {
        
    }
}

@end
