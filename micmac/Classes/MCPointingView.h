//
//  MCPointingView.h
//  micmac
//
//  Created by Bryce Pauken on 2/12/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPointingView : UIView

- (void)dismiss;
- (void)setPoint:(CGPoint)point;
- (void)setTappedBlock:(void (^)())tappedBlock;
- (void)setTitle:(NSString *)title;
- (void)showInView:(UIView *)view;

@end
