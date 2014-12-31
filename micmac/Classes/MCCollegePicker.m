//
//  MCCollegePicker.m
//  micmac
//
//  Created by Bryce Pauken on 12/29/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCCollegePicker.h"

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
        [leftButtonBackgroundGradient setColors:@[(id)[UIColor MCLightBlueColor].CGColor, (id)[[UIColor MCLightBlueColor] colorWithAlphaComponent:0].CGColor]];
        [leftButtonBackgroundGradient setEndPoint:CGPointMake(0.6, 0.5)];
        [leftButtonBackgroundGradient setFrame:leftButtonBackground.bounds];
        [leftButtonBackgroundGradient setStartPoint:CGPointMake(0.25, 0.5)];
        [leftButtonBackground.layer insertSublayer:leftButtonBackgroundGradient atIndex:0];
        
        UIView *rightButtonBackground = [[UIView alloc] initWithFrame:_rightButton.frame];
        [rightButtonBackground setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        CAGradientLayer *rightButtonBackgroundGradient = [CAGradientLayer layer];
        [rightButtonBackgroundGradient setColors:@[(id)[UIColor MCLightBlueColor].CGColor, (id)[[UIColor MCLightBlueColor] colorWithAlphaComponent:0].CGColor]];
        [rightButtonBackgroundGradient setEndPoint:CGPointMake(0.4, 0.5)];
        [rightButtonBackgroundGradient setFrame:leftButtonBackground.bounds];
        [rightButtonBackgroundGradient setStartPoint:CGPointMake(0.75, 0.5)];
        [rightButtonBackground.layer insertSublayer:rightButtonBackgroundGradient atIndex:0];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_spinner setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
        [_spinner setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        
        [self setBackgroundColor:[UIColor MCLightBlueColor]];
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
            newPage = MIN(self.colleges.count-1, self.currentPage+1);
        }
        [UIView animateWithDuration:0.3 animations:^{
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*newPage, 0)];
        }];
    }
}

- (void)checkLocation {
    CLLocation *location = ViewController.lastLocation;
    if(location) {
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
    [label setShadowColor:[UIColor darkGrayColor]];
    [label setShadowOffset:CGSizeMake(0, 1)];
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
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=%@&location=%f,%f&keyword=college+university&radius=16000&types=university",@"AIzaSyBfD0OMiMbhJhVAd969ReRsnJdEsDSEn2U",location.coordinate.latitude,location.coordinate.longitude]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *jsonError;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if(!jsonError && json && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonDictionary = (NSDictionary *)json;
            if([jsonDictionary objectForKey:@"results"]) {
                [self.colleges removeAllObjects];
                for(NSDictionary *result in [jsonDictionary objectForKey:@"results"]) {
                    [self.colleges addObject:[result objectForKey:@"name"]];
                }
                [self showColleges];
            }
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView==self.scrollView) {
        NSInteger page = lround(scrollView.contentOffset.x/scrollView.frame.size.width);
        if (self.currentPage != page) {
            self.currentPage = page;
            
            [self.leftButton setEnabled:page>0];
            [self.rightButton setEnabled:page<self.colleges.count-1];
        }
    }
}

- (void)showColleges {
    [self.scrollView setContentSize:CGSizeMake(self.colleges.count*self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    for(int i=0;i<self.colleges.count;i++) {
        UILabel *label = [self createLabelWithText:[self.colleges objectAtIndex:i]];
        [label setCenter:CGPointMake(i*self.scrollView.bounds.size.width+self.scrollView.bounds.size.width/2, self.scrollView.bounds.size.height/2)];
        [self.scrollView addSubview:label];
    }
    [self.spinner stopAnimating];
    [self.scrollView setHidden:NO];
    [self.leftButton setAlpha:1];
    [self.rightButton setAlpha:1];
    [self scrollViewDidScroll:self.scrollView];
}

@end
