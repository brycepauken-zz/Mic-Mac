//
//  MCComposeView.h
//  micmac
//
//  Created by Bryce Pauken on 2/22/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCComposeView : UIView <UITextFieldDelegate, UITextViewDelegate>

- (instancetype)initInView:(UIView *)view withPlaceholder:(NSString *)placeholder;
- (void)dismiss;
- (void)setGroups:(NSArray *)groups;
- (void)show;
- (NSString *)text;

@end
