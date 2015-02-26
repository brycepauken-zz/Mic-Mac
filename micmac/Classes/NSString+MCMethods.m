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
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

+ (NSString *)timeToHumanReadableString:(NSTimeInterval)time {
    time = [[NSDate date] timeIntervalSince1970]-time;
    if(time < 60) {
        //within last minute
        return @"Just Now";
    }
    else if(time < 3600) {
        //1-59 minutes ago
        int minutes = time/60;
        return [NSString stringWithFormat:@"%i Minute%c Ago",(minutes<=10?minutes:5*(int)round(minutes/5)),(minutes==1?'\0':'s')];
    }
    else if(time < 86400) {
        //1-59 hours ago
        int hours = time/3600;
        return [NSString stringWithFormat:@"%i Hour%c Ago",(hours<=10?hours:5*(int)round(hours/5)),(hours==1?'\0':'s')];
    }
    else {
        //days ago
        int days = time/86400;
        return [NSString stringWithFormat:@"%i Day%c Ago",days,(days==1?'\0':'s')];
    }
}

@end
