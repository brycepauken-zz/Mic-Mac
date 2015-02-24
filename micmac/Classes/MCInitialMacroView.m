//
//  MCInitialMacroView.m
//  micmac
//
//  Created by Bryce Pauken on 2/23/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCInitialMacroView.h"

@interface MCInitialMacroView()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MCInitialMacroView

static const int kContentViewCornerRadius = 10;
static const int kContentViewMargin = 20;
static const int kSubtitleFontSize = 15;
static NSString *kSubtitleMultilineText = @"Select a few topics that\ninterest you to get started.";
static NSString *kSubtitleText = @"Select a few topics that interest you to get started.";
static const int kTitleFontSize = 24;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _contentView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, kContentViewMargin, kContentViewMargin)];
        [_contentView setBackgroundColor:[UIColor MCMainColor]];
        [_contentView.layer setCornerRadius:kContentViewCornerRadius];
        [_contentView.layer setMasksToBounds:YES];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:kTitleFontSize]];
        [_titleLabel setText:@"Just One More Step"];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor MCOffWhiteColor]];
        [_titleLabel sizeToFit];
        [_titleLabel setCenter:CGPointMake(_contentView.frame.size.width/2, 30)];
        [_contentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        [_subtitleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:kSubtitleFontSize]];
        [_subtitleLabel setNumberOfLines:0];
        [_subtitleLabel setText:kSubtitleMultilineText];
        [_subtitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_subtitleLabel setTextColor:[UIColor MCOffWhiteColor]];
        [_subtitleLabel sizeToFit];
        [_subtitleLabel setCenter:CGPointMake(_contentView.frame.size.width/2, 75)];
        [_contentView addSubview:_subtitleLabel];
        
        [self addSubview:_contentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView setFrame:CGRectInset(self.bounds, kContentViewMargin, kContentViewMargin)];
    [self.titleLabel setCenter:CGPointMake(self.contentView.frame.size.width/2, 30)];
    [self.subtitleLabel setFrame:self.contentView.bounds];
    if([kSubtitleText sizeWithFont:self.subtitleLabel.font constrainedToWidth:CGFLOAT_MAX].width<self.contentView.bounds.size.width-20) {
        [self.subtitleLabel setText:@"Select a few topics that interest you to get started."];
        [self.subtitleLabel setCenter:CGPointMake(self.contentView.frame.size.width/2, 60)];
    }
    else {
        [self.subtitleLabel setText:kSubtitleMultilineText];
        [self.subtitleLabel sizeToFit];
        [self.subtitleLabel setCenter:CGPointMake(self.contentView.frame.size.width/2, 75)];
    }
}

@end
