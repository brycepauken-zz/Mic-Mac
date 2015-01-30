//
//  MCCommon.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCCommon.h"

#import "MCAppDelegate.h"
#import "MCMainView.h"

UIViewAutoresizing UIViewAutoResizingFlexibleAll = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
UIViewAutoresizing UIViewAutoResizingFlexibleMargins = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
UIViewAutoresizing UIViewAutoResizingFlexibleSize = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

@implementation MCCommon

+ (MCMainView *)mainView {
    return [(MCAppDelegate *)[[UIApplication sharedApplication] delegate] mainView];
}

@end
