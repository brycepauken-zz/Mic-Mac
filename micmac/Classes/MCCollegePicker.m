//
//  MCCollegePicker.m
//  micmac
//
//  Created by Bryce Pauken on 12/29/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCCollegePicker.h"

#import "MCAlertView.h"
#import "MCViewController.h"

@interface MCCollegePicker()

@property (nonatomic, strong) NSMutableArray *colleges;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation MCCollegePicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _colleges = [[NSMutableArray alloc] init];
        _currentPage = -1;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setDelegate:self];
        [_scrollView setHidden:YES];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        
        UITapGestureRecognizer *scrollViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped)];
        [scrollViewTapRecognizer setCancelsTouchesInView:YES];
        [scrollViewTapRecognizer setEnabled:YES];
        [scrollViewTapRecognizer setNumberOfTapsRequired:1];
        [_scrollView addGestureRecognizer:scrollViewTapRecognizer];
        
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height)];
        [_leftButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_leftButton setAlpha:0];
        [_leftButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [_leftButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-self.bounds.size.height, 0, self.bounds.size.height, self.bounds.size.height)];
        [_rightButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setAlpha:0];
        [_rightButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_rightButton setImage:[UIImage imageNamed:@"ArrowRight"] forState:UIControlStateNormal];
        
        UIView *leftButtonBackground = [[UIView alloc] initWithFrame:_leftButton.frame];
        [leftButtonBackground setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        CAGradientLayer *leftButtonBackgroundGradient = [CAGradientLayer layer];
        [leftButtonBackgroundGradient setColors:@[(id)[UIColor MCMainColor].CGColor, (id)[[UIColor MCMainColor] colorWithAlphaComponent:0].CGColor]];
        [leftButtonBackgroundGradient setEndPoint:CGPointMake(0.6, 0.5)];
        [leftButtonBackgroundGradient setFrame:leftButtonBackground.bounds];
        [leftButtonBackgroundGradient setStartPoint:CGPointMake(0.25, 0.5)];
        [leftButtonBackground.layer insertSublayer:leftButtonBackgroundGradient atIndex:0];
        
        UIView *rightButtonBackground = [[UIView alloc] initWithFrame:_rightButton.frame];
        [rightButtonBackground setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        CAGradientLayer *rightButtonBackgroundGradient = [CAGradientLayer layer];
        [rightButtonBackgroundGradient setColors:@[(id)[UIColor MCMainColor].CGColor, (id)[[UIColor MCMainColor] colorWithAlphaComponent:0].CGColor]];
        [rightButtonBackgroundGradient setEndPoint:CGPointMake(0.4, 0.5)];
        [rightButtonBackgroundGradient setFrame:leftButtonBackground.bounds];
        [rightButtonBackgroundGradient setStartPoint:CGPointMake(0.75, 0.5)];
        [rightButtonBackground.layer insertSublayer:rightButtonBackgroundGradient atIndex:0];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_spinner setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
        [_spinner setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        
        [self setBackgroundColor:[UIColor MCMainColor]];
        [self addSubview:_spinner];
        [self addSubview:_scrollView];
        [self addSubview:leftButtonBackground];
        [self addSubview:_leftButton];
        [self addSubview:rightButtonBackground];
        [self addSubview:_rightButton];
        
        [_spinner startAnimating];
        [self checkLocation];
    }
    return self;
}

- (void)buttonTapped:(UIButton *)sender {
    if(sender==self.leftButton || sender==self.rightButton) {
        NSInteger newPage;
        if(sender == self.leftButton) {
            newPage = MAX(0, self.currentPage-1);
        }
        else {
            newPage = MIN(self.colleges.count, self.currentPage+1);
        }
        [UIView animateWithDuration:0.3 animations:^{
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*newPage, 0)];
        }];
    }
}

- (void)checkLocation {
    CLLocation *location = ViewController.lastLocation;
    BOOL alwaysTrue = 1==1;
    if(alwaysTrue || location) {
        [self getCollegesNearLocation:[location copy]];
    }
    else {
        __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"MCLocationUpdated" object:nil queue:nil usingBlock:^(NSNotification *notification) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            [self getCollegesNearLocation:[ViewController.lastLocation copy]];
        }];
    }
}

- (UILabel *)createLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    [label setNumberOfLines:2];
    //[label setShadowColor:[UIColor darkGrayColor]];
    //[label setShadowOffset:CGSizeMake(0, 1)];
    [label setText:text];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor MCOffWhiteColor]];
    
    CGFloat fontSize = 24;
    CGSize textSize;
    do {
        CGRect textRect = [text boundingRectWithSize:CGSizeMake(self.bounds.size.width-self.bounds.size.height, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy" size:fontSize]} context:nil];
        textSize = CGSizeMake(ceilf(textRect.size.width), ceilf(textRect.size.height));
        if(textSize.height<self.bounds.size.height) {
            break;
        }
        fontSize--;
    } while(fontSize>12);
    [label setFont:[UIFont fontWithName:@"Avenir-Heavy" size:fontSize]];
    [label setFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
    
    return label;
}

- (void)getCollegesNearLocation:(CLLocation *)location {
    self.colleges = [@[@"Default College"] mutableCopy];
    [self showColleges];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView==self.scrollView) {
        NSInteger page = lround(scrollView.contentOffset.x/scrollView.frame.size.width);
        if (self.currentPage != page) {
            self.currentPage = page;
            
            [self.leftButton setEnabled:page>0];
            [self.rightButton setEnabled:page<self.colleges.count];
        }
    }
}

- (void)showColleges {
    [self.scrollView setContentSize:CGSizeMake((self.colleges.count+1)*self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    for(int i=0;i<self.colleges.count+1;i++) {
        NSString *collegeName;
        if(i<self.colleges.count) {
            collegeName = [self.colleges objectAtIndex:i];
        }
        else {
            collegeName = @"Other/None";
        }
        UILabel *label = [self createLabelWithText:collegeName];
        [label setCenter:CGPointMake(i*self.scrollView.bounds.size.width+self.scrollView.bounds.size.width/2, self.scrollView.bounds.size.height/2)];
        [self.scrollView addSubview:label];
    }
    [self.spinner stopAnimating];
    [self.scrollView setHidden:NO];
    [self.leftButton setAlpha:1];
    [self.rightButton setAlpha:1];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)scrollViewTapped {
    if(self.currentPage<self.colleges.count) {
        MCAlertView *alertView = [[MCAlertView alloc] initWithAlertWithTitle:[self.colleges objectAtIndex:self.currentPage] message:@"Is this college correct? You will not be able to select a different one after this point." buttonType:MCAlertViewButtonTypeYesNo];
        __weak MCAlertView *weakAlertView = alertView;
        [alertView setOnButtonTapped:^(int index) {
            [weakAlertView dismiss];
        }];
        [alertView show];
    }
}

@end
