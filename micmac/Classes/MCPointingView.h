//
//  MCPointingView.h
//  micmac
//
//  Created by Bryce Pauken on 2/12/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPointingView : UIView

- (UIView *)contentView;
+ (CGFloat)contentViewWidth;
- (void)dismiss;
- (void)setPoint:(CGPoint)point;
- (void)show;

@end
