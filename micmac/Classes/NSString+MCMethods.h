//
//  NSString+MCMethods.h
//  micmac
//
//  Created by Bryce Pauken on 1/29/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MCMethods)

- (NSString *)md5;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
+ (NSString *)timeToHumanReadableString:(NSTimeInterval)time;

@end
