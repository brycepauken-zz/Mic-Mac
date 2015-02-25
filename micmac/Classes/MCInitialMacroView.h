//
//  MCInitialMacroView.h
//  micmac
//
//  Created by Bryce Pauken on 2/23/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCInitialMacroView : UIView

- (void)setCompletionBlock:(void (^)(NSArray *))completionBlock;
- (void)setGroups:(NSArray *)groups;
- (void)willShow;

@end
