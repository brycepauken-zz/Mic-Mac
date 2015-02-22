//
//  MCComposeView.h
//  micmac
//
//  Created by Bryce Pauken on 2/22/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCComposeView : UIView <UITextViewDelegate>

- (instancetype)initInView:(UIView *)view withPlaceholder:(NSString *)placeholder;
- (void)dismiss;
- (void)show;

@end
