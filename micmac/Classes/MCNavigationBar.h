//
//  MCNavigationBar.h
//  micmac
//
//  Created by Bryce Pauken on 2/1/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCNavigationBar : UIView

- (void)setDropDownBlock:(void (^)())dropDownBlock;
- (void)setLeftButtonImage:(UIImage *)image;
- (void)setLeftButtonTapped:(void (^)())leftButtonTapped;
- (void)setPage:(NSInteger)page;
- (void)setRightButtonImage:(UIImage *)image;
- (void)setRightButtonTapped:(void (^)())rightButtonTapped;
- (void)setScrollFactor:(CGFloat)factor;
- (void)setTitle:(NSString *)title;
- (void)setTitles:(NSArray *)titles;

@end
