//
//  MCAlertView.h
//  micmac
//
//  Created by Bryce Pauken on 1/27/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MCAlertViewButtonType) {
    MCAlertViewButtonTypeNone,
    MCAlertViewButtonTypeYesNo
};

@interface MCAlertView : UIView

- (instancetype)initWithAlertWithTitle:(NSString *)title message:(NSString *)message buttonType:(MCAlertViewButtonType)buttonType;
- (void)dismiss;
- (void)setOnButtonTapped:(void (^)(int))onButtonTapped;
- (void)show;

@end
