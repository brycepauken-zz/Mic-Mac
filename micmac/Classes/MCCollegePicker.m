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
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation MCCollegePicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _colleges = [[NSMutableArray alloc] init];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setHidden:YES];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_spinner setAutoresizingMask:UIViewAutoResizingFlexibleMargins];
        [_spinner setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        
        [self setBackgroundColor:[UIColor MCLightBlueColor]];
        [self addSubview:_spinner];
        [self addSubview:_scrollView];
        
        [_spinner startAnimating];
        [self checkLocation];
    }
    return self;
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
    [label setFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]];
    [label setShadowColor:[UIColor darkGrayColor]];
    [label setShadowOffset:CGSizeMake(0, 1)];
    [label setText:text];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor MCOffWhiteColor]];
    
    [label sizeToFit];
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

- (void)showColleges {
    /*[self.scrollView setContentSize:CGSizeMake(self.colleges.count*self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    for(int i=0;i<self.colleges.count;i++) {
        UILabel *label = [self createLabelWithText:[self.colleges objectAtIndex:i]];
        [label setCenter:CGPointMake(i*self.scrollView.bounds.size.width+self.scrollView.bounds.size.width/2, self.scrollView.bounds.size.height/2)];
        [self.scrollView addSubview:label];
    }
    [self.spinner stopAnimating];
    [self.scrollView setHidden:NO];*/
}

@end
