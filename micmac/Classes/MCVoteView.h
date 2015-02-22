//
//  MCVoteView.h
//  micmac
//
//  Created by Bryce Pauken on 2/21/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCVoteView : UIView

- (instancetype)initAndSize;
- (void)setPoints:(NSInteger)points;
+ (CGFloat)widthForViewWithPoints:(NSInteger)points;

@end
