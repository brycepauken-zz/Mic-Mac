//
//  MCStartView.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCStartView.h"

@interface MCStartView()

@property (nonatomic, strong) NSMutableArray *largeBubbles;
@property (nonatomic, strong) UIView *largeBubblesContainer;
@property (nonatomic, strong) NSLock *largeBubblesLock;
@property (nonatomic) CGPoint largeBubblesNextCenter;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UIView *logoContainer;
@property (nonatomic, strong) NSArray *pages;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *smallBubbles;
@property (nonatomic, strong) UIView *smallBubblesContainer;
@property (nonatomic, strong) UIDynamicAnimator *smallBubblesDynamicAnimator;
@property (nonatomic, strong) UIDynamicItemBehavior *smallBubblesDynamicBehavior;
@property (nonatomic, strong) UIGravityBehavior *smallBubblesGravityBehavior;
@property (nonatomic, strong) NSLock *smallBubblesLock;
@property (nonatomic) CGPoint smallBubblesNextCenter;
@property (nonatomic) NSInteger visiblePages;

@end

@implementation MCStartView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [_scrollView setDelegate:self];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        
        int logoSize = MIN(self.bounds.size.width, self.bounds.size.height)/2;
        _pages = @[[[UIView alloc] init], [[UIView alloc] init], [[UIView alloc] init], [[UIView alloc] init]];
        for(int i=0;i<_pages.count;i++) {
            UIView *page = [_pages objectAtIndex:i];
            [page setFrame:CGRectMake(i*_scrollView.bounds.size.width, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
            [page setTag:i];
            
            if(i==0) {
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"Mic Mac lets you talk\nanonymously about topics\non a large, Macro level..."];
                [text beginEditing];
                [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:20] range:NSMakeRange(0, text.length)];
                [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 8)];
                [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Black" size:20] range:NSMakeRange(0, 8)];
                [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(59, 5)];
                [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Black" size:20] range:NSMakeRange(59, 5)];
                [text endEditing];
                UIView *labelContainer = [self createLabelInContainerWithText:text];
                [labelContainer setCenter:CGPointMake(page.bounds.size.width/2, page.bounds.size.height*3/4)];
                [labelContainer setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
                [page addSubview:labelContainer];
            }
            else if(i==1) {
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"... and about subjects that\nare local to you in your\nown Micro community."];
                [text beginEditing];
                [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:20] range:NSMakeRange(0, text.length)];
                [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(57, 5)];
                [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Black" size:20] range:NSMakeRange(57, 5)];
                [text endEditing];
                UIView *labelContainer = [self createLabelInContainerWithText:text];
                [labelContainer setCenter:CGPointMake(page.bounds.size.width/2, page.bounds.size.height*3/4)];
                [labelContainer setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
                [page addSubview:labelContainer];
            }
            else if(i==2 || i==3) {
                UIView *imageContainer = [[UIView alloc] initWithFrame:CGRectZero];
                [imageContainer setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/3)];
                [imageContainer setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
                UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(i==2?@"Location":@"School")]];
                [image setFrame:CGRectMake(-logoSize/2, -logoSize/2, logoSize, logoSize)];
                [imageContainer addSubview:image];
                [page addSubview:imageContainer];
            }
            
            [_scrollView addSubview:page];
        }
        _visiblePages = 3;
        
        UIView *pageControlContainer = [[UIView alloc] initWithFrame:CGRectZero];
        [pageControlContainer setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
        [pageControlContainer setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height*13/14)];
        _pageControl = [[UIPageControl alloc] init];
        [_pageControl setNumberOfPages:_visiblePages];
        [_pageControl sizeToFit];
        [_pageControl setCenter:CGPointZero];
        [pageControlContainer addSubview:_pageControl];
        
        _largeBubbles = [[NSMutableArray alloc] init];
        _largeBubblesContainer = [[UIView alloc] initWithFrame:self.bounds];
        [_largeBubblesContainer setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        _largeBubblesLock = [[NSLock alloc] init];
        _largeBubblesNextCenter = CGPointZero;
        
        _smallBubbles = [[NSMutableArray alloc] init];
        _smallBubblesContainer = [[UIView alloc] initWithFrame:self.bounds];
        [_smallBubblesContainer setAlpha:0];
        [_smallBubblesContainer setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        _smallBubblesDynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:_smallBubblesContainer];
        _smallBubblesDynamicBehavior = [[UIDynamicItemBehavior alloc] init];
        _smallBubblesGravityBehavior = [[UIGravityBehavior alloc] init];
        [_smallBubblesGravityBehavior setMagnitude:0.5];
        [_smallBubblesDynamicAnimator addBehavior:_smallBubblesDynamicBehavior];
        [_smallBubblesDynamicAnimator addBehavior:_smallBubblesGravityBehavior];
        _smallBubblesLock = [[NSLock alloc] init];
        _smallBubblesNextCenter = CGPointZero;
        
        _logoContainer = [[UIView alloc] initWithFrame:CGRectZero];
        [_logoContainer setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/3)];
        [_logoContainer setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
        _logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
        [_logo setFrame:CGRectMake(-logoSize/2, -logoSize/2, logoSize, logoSize)];
        [_logoContainer addSubview:_logo];
        
        [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(createLargeBubble) userInfo:nil repeats:YES];
        [self createLargeBubble];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(createSmallBubble) userInfo:nil repeats:YES];
        [self createSmallBubble];
        
        [self setBackgroundColor:[UIColor MCLightBlueColor]];
        [self addSubview:_largeBubblesContainer];
        [self addSubview:_smallBubblesContainer];
        [self addSubview:_scrollView];
        [self addSubview:pageControlContainer];
        [self addSubview:_logoContainer];
    }
    return self;
}

- (void)createLargeBubble {
    static const int bubbleSize = 200;
    
    CGPoint bubbleCenter = CGPointMake(self.largeBubblesNextCenter.x, self.largeBubblesNextCenter.y);
    self.largeBubblesNextCenter = CGPointMake(bubbleSize/4+arc4random_uniform(self.bounds.size.width-bubbleSize/2), bubbleSize/4+arc4random_uniform(self.bounds.size.height-bubbleSize/2));
    if(CGPointEqualToPoint(bubbleCenter, CGPointZero)) {
        bubbleCenter = CGPointMake(self.largeBubblesNextCenter.x, self.largeBubblesNextCenter.y);
    }
    
    UIView *bubble = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bubbleSize, bubbleSize)];
    [bubble setCenter:bubbleCenter];
    [self.largeBubblesLock lock];
    [self.largeBubbles addObject:bubble];
    NSArray *bubbles = [self.largeBubbles copy];
    [self.largeBubblesLock unlock];
    
    [bubble setAlpha:0];
    [bubble setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
    [bubble setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)];
    [bubble setUserInteractionEnabled:NO];
    [bubble.layer setBorderColor:[UIColor MCOffWhiteColor].CGColor];
    [bubble.layer setBorderWidth:4];
    [bubble.layer setCornerRadius:bubbleSize/2];
    [self.largeBubblesContainer addSubview:bubble];
    
    CGFloat duration = 1+drand48()*4;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [bubble setAlpha:0.5];
        [bubble setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75)];
    } completion:^(BOOL finished) {
        if(finished) {
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [bubble setAlpha:0];
                [bubble setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if(finished) {
                    [self.largeBubblesLock lock];
                    [self.largeBubbles removeObject:bubble];
                    [self.largeBubblesLock unlock];
                }
            }];
        }
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        CGFloat bubbleX = 0;
        CGFloat bubbleY = 0;
        while(true) {
            bubbleX = bubbleSize/4+arc4random_uniform(self.bounds.size.width-bubbleSize/2);
            bubbleY = bubbleSize/4+arc4random_uniform(self.bounds.size.height-bubbleSize/2);
            CGFloat maxDist = 0;
            for(UIView *bubble in bubbles) {
                CGFloat dx = fabsf(bubbleX - bubble.center.x);
                CGFloat dy = fabsf(bubbleY - bubble.center.y);
                CGFloat maxDx = MAX(bubble.center.x, self.bounds.size.width-bubble.center.x);
                CGFloat maxDy = MAX(bubble.center.y, self.bounds.size.height-bubble.center.y);
                CGFloat dist = sqrt(dx*dx+dy*dy)/sqrt(maxDx*maxDx+maxDy*maxDy);
                if(dist>maxDist) {
                    maxDist = dist;
                }
            }
            if(drand48()<maxDist) {
                break;
            }
        }
        
        self.largeBubblesNextCenter = CGPointMake(bubbleX, bubbleY);
    });
}

- (void)createSmallBubble {
    static const int bubbleSize = 25;
    
    CGPoint bubbleCenter = CGPointMake(self.smallBubblesNextCenter.x, self.smallBubblesNextCenter.y);
    self.smallBubblesNextCenter = CGPointMake(bubbleSize/4+arc4random_uniform(self.bounds.size.width-bubbleSize/2), bubbleSize/4+arc4random_uniform(self.bounds.size.height/2-bubbleSize/2));
    if(CGPointEqualToPoint(bubbleCenter, CGPointZero)) {
        bubbleCenter = CGPointMake(self.smallBubblesNextCenter.x, self.smallBubblesNextCenter.y);
    }
    
    UIView *bubble = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bubbleSize, bubbleSize)];
    [bubble setCenter:bubbleCenter];
    [self.smallBubblesLock lock];
    [self.smallBubbles addObject:bubble];
    NSArray *bubbles = [self.smallBubbles copy];
    [self.smallBubblesLock unlock];
    
    [bubble setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0, 0)];
    [bubble setUserInteractionEnabled:NO];
    [bubble.layer setBorderColor:[UIColor MCOffWhiteColor].CGColor];
    [bubble.layer setBorderWidth:2];
    [bubble.layer setCornerRadius:bubbleSize/2];
    [self.smallBubblesContainer addSubview:bubble];
    [self.smallBubblesDynamicBehavior addItem:bubble];
    [self.smallBubblesGravityBehavior addItem:bubble];
    
    [self.smallBubblesDynamicBehavior addLinearVelocity:CGPointMake(((int)arc4random_uniform(100))-50, ((int)arc4random_uniform(100))-300) forItem:bubble];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [bubble setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
    } completion:^(BOOL finished) {
        if(finished) {
            [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [bubble setAlpha:0];
            } completion:^(BOOL finished) {
                if(finished) {
                    [self.smallBubblesLock lock];
                    [self.smallBubbles removeObject:bubble];
                    [self.smallBubblesLock unlock];
                }
            }];
        }
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        CGFloat bubbleX = 0;
        CGFloat bubbleY = 0;
        while(true) {
            bubbleX = bubbleSize/4+arc4random_uniform(self.bounds.size.width-bubbleSize/2);
            bubbleY = bubbleSize/4+arc4random_uniform(self.bounds.size.height*3/4-bubbleSize/2);
            CGFloat maxDist = 0;
            for(UIView *bubble in bubbles) {
                CGFloat dx = fabsf(bubbleX - bubble.center.x);
                CGFloat dy = fabsf(bubbleY - bubble.center.y);
                CGFloat maxDx = MAX(bubble.center.x, self.bounds.size.width-bubble.center.x);
                CGFloat maxDy = MAX(bubble.center.y, self.bounds.size.height-bubble.center.y);
                CGFloat dist = sqrt(dx*dx+dy*dy)/sqrt(maxDx*maxDx+maxDy*maxDy);
                if(dist>maxDist) {
                    maxDist = dist;
                }
            }
            if(drand48()<maxDist) {
                break;
            }
        }
        
        self.smallBubblesNextCenter = CGPointMake(bubbleX, bubbleY);
    });
}

- (UIView *)createLabelInContainerWithText:(NSAttributedString *)text {
    UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
    
    UILabel *label = [[UILabel alloc] init];
    [label setAttributedText:text];
    [label setNumberOfLines:0];
    [label setShadowColor:[UIColor darkGrayColor]];
    [label setShadowOffset:CGSizeMake(0, 1)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor MCOffWhiteColor]];
    
    [container addSubview:label];
    [label sizeToFit];
    [label setCenter:CGPointZero];
    return container;
}

- (void)layoutSubviews {
    [self updateScrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.scrollView) {
        static NSInteger previousPage = 0;
        
        CGFloat offset = scrollView.contentOffset.x/scrollView.frame.size.width;
        [self.largeBubblesContainer setAlpha:MIN(1, MAX(0, 1-offset))];
        [self.smallBubblesContainer setAlpha:MIN(1, MAX(0, offset<=1?offset:2-offset))];
        [self.logo setCenter:CGPointMake((MAX(1, offset)-1)*-self.scrollView.bounds.size.width, 0)];
        
        [self.logo setAlpha:MIN(1, MAX(0, 2-offset))];
        NSInteger page = lround(offset);
        if(previousPage != page) {
            previousPage = page;
            [self.scrollView setTag:page];
            [self.pageControl setCurrentPage:page];
        }
    }
}

- (void)updateScrollView {
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width*self.visiblePages, self.scrollView.bounds.size.height)];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*self.scrollView.tag, 0)];
    for(UIView *page in self.pages) {
        [page setFrame:CGRectMake(page.tag*self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    }
}

@end
