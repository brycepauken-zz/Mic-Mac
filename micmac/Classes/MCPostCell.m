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
@property (nonatomic, strong) UILongPressGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic) BOOL initialized;
@property (nonatomic, strong) UIView *selectedBackground;
@property (nonatomic, strong) UIView *topDivider;
@property (nonatomic, strong) MCVoteView *voteView;

@end

@implementation MCPostCell

static const int kContentFontSize = 18;
static const int kContentVerticalMargin = 16;
static const int kInfoFontSize = 14;
static const int kVoteViewHorzontalMargin = 10;
static const int kVoteViewSize = 32;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        _initialized = NO;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(gestureRecognizer == self.gestureRecognizer) {
        if(CGRectContainsPoint(self.voteView.frame, [touch locationInView:self])) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

+ (CGFloat)heightForCellOfWidth:(CGFloat)width withText:(NSString *)text points:(NSInteger)points {
    static UIFont *contentFont;
    static UIFont *infoFont;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contentFont = [UIFont systemFontOfSize:kContentFontSize];
        infoFont = [UIFont systemFontOfSize:kInfoFontSize];
    });
    CGSize contentSize = [text sizeWithFont:contentFont constrainedToWidth:width-kVoteViewSize-kVoteViewHorzontalMargin*3];
    CGSize infoSize = [@"Just Now (Placeholder)" sizeWithFont:infoFont constrainedToWidth:MAXFLOAT];
    return MAX(contentSize.height+kContentVerticalMargin*2.5+infoSize.height, 80);
}

- (void)longGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self setInnerHighlighted:YES animated:NO];
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setInnerHighlighted:NO animated:NO];
    }
}

- (void)repositionSubviews {
    CGFloat textWidth = self.bounds.size.width-self.voteView.frame.size.width-kVoteViewHorzontalMargin*3;
    CGSize contentSize = [self.contentLabel.text sizeWithFont:self.contentLabel.font constrainedToWidth:textWidth];
    [self.contentLabel setFrame:CGRectMake(kVoteViewHorzontalMargin, kContentVerticalMargin, contentSize.width, contentSize.height)];
    
    CGSize infoSize = [self.infoLabel.text sizeWithFont:self.infoLabel.font constrainedToWidth:MAXFLOAT];
    [self.infoLabel setFrame:CGRectMake(kVoteViewHorzontalMargin, self.bounds.size.height-infoSize.height-kVoteViewHorzontalMargin, textWidth, infoSize.height)];
    
    [self.voteView setCenter:CGPointMake(self.bounds.size.width-self.voteView.frame.size.width/2-kVoteViewHorzontalMargin, self.bounds.size.height/2)];
}

- (void)setBothDivividersVisible:(BOOL)bothVisible {
    [self.topDivider setHidden:!bothVisible];
}

- (void)setContent:(NSString *)content withPoints:(NSInteger)points postTime:(NSTimeInterval)postTime numberOfReplies:(NSInteger)replies {
    [self.contentLabel setText:content];
    [self.infoLabel setText:[NSString stringWithFormat:@"%@ | %li Replies",[NSString timeToHumanReadableString:postTime],replies]];
    
    [self repositionSubviews];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self repositionSubviews];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {}

- (void)setInnerHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self.selectedBackground setHidden:!highlighted];
}

- (void)setUpCell {
    [self setInitialized:YES];
    __weak MCPostCell *weakSelf = self;
    
    [self setClipsToBounds:YES];
    
    self.selectedBackground = [[UIView alloc] initWithFrame:self.bounds];
    [self.selectedBackground setAutoresizingMask:UIViewAutoResizingFlexibleSize];
    [self.selectedBackground setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    [self.selectedBackground setHidden:YES];
    
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
    
    self.infoLabel = [[UILabel alloc] init];
    [self.infoLabel setFont:[UIFont systemFontOfSize:kInfoFontSize]];
    [self.infoLabel setOpaque:YES];
    [self.infoLabel setTextColor:[UIColor MCLightMainColor]];
    
    self.voteView = [[MCVoteView alloc] initWithFrame:CGRectMake(0, 0, kVoteViewSize, kVoteViewSize)];
    [self.voteView setOpaque:YES];
    [self.voteView setVoteChangedBlock:^(MCVoteViewState state) {
        [weakSelf voteViewStateChanged:state];
    }];
    
    self.gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self.gestureRecognizer setCancelsTouchesInView:NO];
    [self.gestureRecognizer setDelegate:self];
    [self.gestureRecognizer setMinimumPressDuration:0];
    [self addGestureRecognizer:self.gestureRecognizer];
    
    [self setBackgroundColor:[UIColor MCOffWhiteColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self addSubview:self.selectedBackground];
    [self addSubview:self.topDivider];
    [self addSubview:self.bottomDivider];
    [self addSubview:self.contentLabel];
    [self addSubview:self.infoLabel];
    [self addSubview:self.voteView];
}

- (void)voteViewStateChanged:(MCVoteViewState)state {
    if(state == MCVoteViewStateUpVoted) {
        UIView *circleOverlay = [[UIView alloc] initWithFrame:self.voteView.frame];
        [circleOverlay setUserInteractionEnabled:NO];
        
        CAShapeLayer *circleOverlayLayer = [CAShapeLayer layer];
        [circleOverlayLayer setFillColor:nil];
        [circleOverlayLayer setLineWidth:5];
        [circleOverlayLayer setPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(circleOverlay.bounds.size.width/2, circleOverlay.bounds.size.height/2) radius:circleOverlay.bounds.size.width/2 startAngle:0 endAngle:M_PI*2 clockwise:NO].CGPath];
        [circleOverlayLayer setStrokeColor:[UIColor MCMainColor].CGColor];
        
        [UIView animateWithDuration:0.5 animations:^{
            [circleOverlay setAlpha:0];
            [circleOverlay setTransform:CGAffineTransformMakeScale(5, 5)];
        } completion:^(BOOL finished) {
            [circleOverlay removeFromSuperview];
        }];
        
        [circleOverlay.layer addSublayer:circleOverlayLayer];
        [self addSubview:circleOverlay];
    }
}

@end
