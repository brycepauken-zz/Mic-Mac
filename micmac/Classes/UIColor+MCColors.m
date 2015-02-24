//
//  UIColor+MCColors.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UIColor+MCColors.h"

@implementation UIColor (MCColors)

+ (UIColor *)MCLightGrayColor {
    static UIColor *lightGrayColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lightGrayColor = [UIColor colorWithWhite:0.8 alpha:1];
    });
    
    return lightGrayColor;
}

+ (UIColor *)MCLightMainColor {
    static UIColor *lightMainColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lightMainColor = [UIColor colorWithRed:237/255.0f green:128/255.0f blue:133/255.0f alpha:1];
    });
    
    return lightMainColor;
}

+ (UIColor *)MCMainColor {
    static UIColor *mainColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        mainColor = [UIColor colorWithRed:231/255.0f green:85/255.0f blue:93/255.0f alpha:1];
    });
    
    return mainColor;
}

+ (UIColor *)MCMoreOffBlackColor {
    static UIColor *moreOffBlackColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        moreOffBlackColor = [UIColor colorWithWhite:0.1 alpha:1];
    });
    
    return moreOffBlackColor;
}

+ (UIColor *)MCMoreOffWhiteColor {
    static UIColor *moreOffWhiteColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        moreOffWhiteColor = [UIColor colorWithWhite:0.9 alpha:1];
    });
    
    return moreOffWhiteColor;
}

+ (UIColor *)MCOffBlackColor {
    static UIColor *offBlackColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        offBlackColor = [UIColor colorWithWhite:0.05 alpha:1];
    });
    
    return offBlackColor;
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
