//
//  MCCommon.h
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MCAlertView.h"
#import "NSAttributedString+MCMethods.h"
#import "NSString+MCMethods.h"
#import "UIColor+MCColors.h"

#define ViewController ((MCViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController])

extern UIViewAutoresizing UIViewAutoResizingFlexibleAll;
extern UIViewAutoresizing UIViewAutoResizingFlexibleMargins;
extern UIViewAutoresizing UIViewAutoResizingFlexibleSize;

@class MCMainView;

@interface MCCommon : NSObject

+ (MCMainView *)mainView;

@end
