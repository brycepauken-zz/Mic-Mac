//
//  MCSearchBar.m
//  micmac
//
//  Created by Bryce Pauken on 3/1/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCSearchBar.h"

@interface MCSearchBar()

@property (nonatomic, strong) UIImageView *searchImageView;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation MCSearchBar

static const int kBorderWidth = 2;
static const int kCornerRadius = 4;
static const int kFontSize = 16;
static const int kImageMargins = 4;
static const int kTextfieldMargins = 2;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height*2, self.bounds.size.height)];
        [_searchImageView setImage:[self searchImage]];
        
        _textField = [[UITextField alloc] init];
        [_textField setFont:[UIFont fontWithName:@"Avenir-Heavy" size:kFontSize]];
        [_textField setTextColor:[UIColor MCOffWhiteColor]];
        [[UITextField appearance] setTintColor:[UIColor MCOffWhiteColor]];
        
        [self setBackgroundColor:[UIColor MCMainColor]];
        [self.layer setBorderColor:[UIColor MCOffWhiteColor].CGColor];
        [self.layer setBorderWidth:kBorderWidth];
        [self.layer setCornerRadius:kCornerRadius];
        
        [self addSubview:_searchImageView];
        [self addSubview:_textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.textField setFrame:CGRectMake(self.bounds.size.height+kImageMargins+kTextfieldMargins, kTextfieldMargins+1, self.bounds.size.width-self.bounds.size.height-kTextfieldMargins*2-kImageMargins*2, self.bounds.size.height-kTextfieldMargins*2)];
}

- (UIImage *)searchImage {
    CGFloat imageSize = self.bounds.size.height;
    CGRect imageRect = CGRectMake(0, 0, imageSize*2, imageSize);
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, false, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor MCOffWhiteColor].CGColor);
    
    UIBezierPath *bezier = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(kImageMargins*2, kImageMargins*2, imageSize/2-kImageMargins, imageSize/2-kImageMargins)];
    CGFloat handleOffset = (imageSize/2)*sqrtf(2)-((imageSize/4)*(sqrtf(2)-1));
    [bezier moveToPoint:CGPointMake(handleOffset, handleOffset)];
    [bezier addLineToPoint:CGPointMake(imageSize-kImageMargins*1.5, imageSize-kImageMargins*1.5)];
    [bezier moveToPoint:CGPointMake(imageSize, 0)];
    [bezier addLineToPoint:CGPointMake(imageSize, imageSize)];
    [bezier setLineWidth:kBorderWidth];
    [bezier stroke];
    CGContextAddPath(ctx, bezier.CGPath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
