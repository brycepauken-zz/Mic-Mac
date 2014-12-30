//
//  ViewController.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCViewController.h"

#import "MCMainView.h"

@interface MCViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MCMainView *mainView;

@end

@implementation MCViewController

- (instancetype)init {
    self = [super init];
    if(self) {
        _mainView = [[MCMainView alloc] initWithFrame:self.view.bounds];
        [_mainView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [self.view addSubview:_mainView];
        
        [self setNeedsStatusBarAppearanceUpdate];
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCLocationAuthorizationChanged" object:nil userInfo:@{@"status":[NSNumber numberWithInteger:status]}];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)startLocationManager {
    if(!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    }
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self locationManager:self.locationManager didChangeAuthorizationStatus:[CLLocationManager authorizationStatus]];
    [self.locationManager startUpdatingLocation];
    NSLog(@"started");
}

@end
