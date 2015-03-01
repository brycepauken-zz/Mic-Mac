//
//  MCActivityIndicator.h
//  micmac
//
//  Created by Bryce Pauken on 2/6/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCActivityIndicatorView : UIView

- (void)setShouldHideCompletely:(BOOL)shouldHideCompletely;
- (void)startAnimatingWithFadeIn:(BOOL)fadeIn;
- (void)stopAnimating;

@end
