//
//  ViewController.h
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface MCViewController : UIViewController <CLLocationManagerDelegate>

- (void)startLocationManager;

@end

