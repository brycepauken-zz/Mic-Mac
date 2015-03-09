//
//  NSString+MCMethods.h
//  micmac
//
//  Created by Bryce Pauken on 1/29/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (MCMethods)

- (CGSize)sizeConstrainedToWidth:(CGFloat)width singleLine:(BOOL)singleLine;

@end
