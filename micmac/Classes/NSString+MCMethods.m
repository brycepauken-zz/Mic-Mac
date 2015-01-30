//
//  NSString+MCMethods.m
//  micmac
//
//  Created by Bryce Pauken on 1/29/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "NSString+MCMethods.h"

@implementation NSString (MCMethods)

- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

@end
