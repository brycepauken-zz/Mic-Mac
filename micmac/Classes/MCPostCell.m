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
@property (nonatomic) BOOL initialized;
@property (nonatomic, strong) UIView *selectedBackground;
@property (nonatomic, strong) UIView *topDivider;
@property (nonatomic, strong) MCVoteView *voteView;

@end

@implementation MCPostCell

static const int kContentFontSize = 18;
static const int kContentVerticalMargin = 16;
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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contentFont = [UIFont systemFontOfSize:kContentFontSize];
    });
    CGSize contentSize = [text sizeWithFont:contentFont constrainedToWidth:width-kVoteViewSize-kVoteViewHorzontalMargin*3];
    return MAX(contentSize.height+kContentVerticalMargin*2, 80);
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
    [self.voteView setCenter:CGPointMake(self.bounds.size.width-self.voteView.frame.size.width/2-kVoteViewHorzontalMargin, self.bounds.size.height/2)];
}

- (void)setBothDivividersVisible:(BOOL)bothVisible {
    [self.topDivider setHidden:!bothVisible];
}

- (void)setContent:(NSString *)content withPoints:(NSInteger)points {
    [self.contentLabel setText:content];
    CGSize contentSize = [content sizeWithFont:self.contentLabel.font constrainedToWidth:self.bounds.size.width-self.voteView.frame.size.width-kVoteViewHorzontalMargin*3];
    [self.contentLabel setFrame:CGRectMake(kVoteViewHorzontalMargin, kContentVerticalMargin, contentSize.width, contentSize.height)];
    
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
    
    self.voteView = [[MCVoteView alloc] initWithFrame:CGRectMake(0, 0, kVoteViewSize, kVoteViewSize)];
    [self.voteView setOpaque:YES];
    
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
    [self addSubview:self.voteView];
}

@end
