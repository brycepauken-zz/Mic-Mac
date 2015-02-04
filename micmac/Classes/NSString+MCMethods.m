//
//  NSString+MCMethods.m
//  micmac
//
//  Created by Bryce Pauken on 1/29/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "NSString+MCMethods.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MCMethods)

- (NSString *)md5 {
    const char *cString = self.UTF8String;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cString, (int)strlen(cString), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02X", digest[i]];
    }
    
    return  output;
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

@end
