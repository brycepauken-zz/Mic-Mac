//
//  MCPageView.h
//  micmac
//
//  Created by Bryce Pauken on 2/1/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCNavigationBar;

@interface MCPageView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) MCNavigationBar *navigationBar;

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name;

@end
