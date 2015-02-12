//
//  MCStartView.h
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface MCStartView : UIView <CLLocationManagerDelegate, UIScrollViewDelegate>

- (void)setHiddenBlock:(void (^)())hiddenBlock;

@end
