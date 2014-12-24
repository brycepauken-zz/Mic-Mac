//
//  UIColor+MCColors.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UIColor+MCColors.h"

@implementation UIColor (MCColors)

+ (UIColor *)MCLightBlueColor {
    static UIColor *lightBlueColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lightBlueColor = [UIColor colorWithRed:75/255.0f green:154/255.0f blue:200/255.0f alpha:1];
    });
    
    return lightBlueColor;
}

+ (UIColor *)MCOffWhiteColor {
    static UIColor *offWhiteColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        offWhiteColor = [UIColor colorWithWhite:0.95 alpha:1];
    });
    
    return offWhiteColor;
}

@end
