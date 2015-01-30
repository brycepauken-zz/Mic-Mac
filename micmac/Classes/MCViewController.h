//
//  ViewController.h
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class MCMainView;

@interface MCViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation *lastLocation;

- (MCMainView *)mainView;
- (void)startLocationManager;

@end

