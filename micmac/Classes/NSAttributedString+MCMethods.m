//
//  NSString+MCMethods.m
//  micmac
//
//  Created by Bryce Pauken on 1/29/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "NSAttributedString+MCMethods.h"

@implementation NSAttributedString (MCMethods)

- (CGSize)sizeConstrainedToWidth:(CGFloat)width singleLine:(BOOL)singleLine {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, singleLine?0.0:CGFLOAT_MAX) options:((singleLine?NSStringDrawingTruncatesLastVisibleLine:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)) context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

@end
