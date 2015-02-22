//
//  MCPostCell.m
//  micmac
//
//  Created by Bryce Pauken on 2/18/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPostCell.h"

#import "MCVoteView.h"

@interface MCPostCell()

@property (nonatomic, strong) UIView *bottomDivider;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic) BOOL initialized;
@property (nonatomic, strong) UIView *topDivider;
@property (nonatomic, strong) MCVoteView *voteView;

@end

@implementation MCPostCell

static const int kContentFontSize = 18;
static const int kContentVerticalMargin = 16;
static const int kVoteViewHorzontalMargin = 10;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        _initialized = NO;
    }
    return self;
}

+ (CGFloat)heightForCellOfWidth:(CGFloat)width withText:(NSString *)text points:(NSInteger)points {
    static UIFont *contentFont;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contentFont = [UIFont systemFontOfSize:kContentFontSize];
    });
    CGSize contentSize = [text sizeWithFont:contentFont constrainedToWidth:width-[MCVoteView widthForViewWithPoints:points]-kVoteViewHorzontalMargin*3];
    return MAX(contentSize.height+kContentVerticalMargin*2, 80);
}

- (void)repositionSubviews {
    [self.voteView setCenter:CGPointMake(self.bounds.size.width-self.voteView.frame.size.width/2-kVoteViewHorzontalMargin, self.bounds.size.height/2)];
}

- (void)setBothDivividersVisible:(BOOL)bothVisible {
    [self.topDivider setHidden:!bothVisible];
}

- (void)setContent:(NSString *)content withPoints:(NSInteger)points {
    [self.voteView setPoints:points];
    [self.voteView sizeToFit];
    
    [self.contentLabel setText:content];
    CGSize contentSize = [content sizeWithFont:self.contentLabel.font constrainedToWidth:self.bounds.size.width-self.voteView.frame.size.width-kVoteViewHorzontalMargin*3];
    [self.contentLabel setFrame:CGRectMake(kVoteViewHorzontalMargin, kContentVerticalMargin, contentSize.width, contentSize.height)];
    
    [self repositionSubviews];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self repositionSubviews];
}

- (void)setUpCell {
    [self setInitialized:YES];
    
    self.topDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
    [self.topDivider setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
    [self.topDivider setBackgroundColor:[UIColor MCLightGrayColor]];
    self.bottomDivider = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
    [self.bottomDivider setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
    [self.bottomDivider setBackgroundColor:[UIColor MCLightGrayColor]];
    
    self.contentLabel = [[UILabel alloc] init];
    [self.contentLabel setFont:[UIFont systemFontOfSize:kContentFontSize]];
    [self.contentLabel setNumberOfLines:0];
    [self.contentLabel setOpaque:YES];
    [self.contentLabel setTextColor:[UIColor darkGrayColor]];
    
    self.voteView = [[MCVoteView alloc] initAndSize];
    [self.voteView setOpaque:YES];
    
    [self setBackgroundColor:[UIColor MCOffWhiteColor]];
    
    [self addSubview:self.topDivider];
    [self addSubview:self.bottomDivider];
    [self addSubview:self.contentLabel];
    [self addSubview:self.voteView];
}



@end
