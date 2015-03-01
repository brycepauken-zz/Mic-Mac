//
//  UIColor+MCColors.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UIColor+MCColors.h"

@implementation UIColor (MCColors)

- (UIColor *)darkerColorByPercent:(CGFloat)percent {
    percent = 1-percent;
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:r*percent green:g*percent blue:b*percent alpha:a];
    }
    return nil;
}

- (UIColor *)lighterColorByPercent:(CGFloat)percent {
    percent = 1-percent;
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:1-(1-r)*percent green:1-(1-g)*percent blue:1-(1-b)*percent alpha:a];
    }
    return nil;
}

+ (UIColor *)MCLighterMainColor {
    static UIColor *lighterMainColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lighterMainColor = [[self MCMainColor] lighterColorByPercent:0.35];
    });
    
    return lighterMainColor;
}

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
        lightMainColor = [[self MCMainColor] lighterColorByPercent:0.25];
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
