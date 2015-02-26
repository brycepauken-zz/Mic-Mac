//
//  MCPostCell.h
//  micmac
//
//  Created by Bryce Pauken on 2/18/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCVoteView.h"

@interface MCPostCell : UITableViewCell <UIGestureRecognizerDelegate>

+ (CGFloat)heightForCellOfWidth:(CGFloat)width withText:(NSString *)text showGroups:(BOOL)groups;
- (BOOL)initialized;
- (void)setBothDivividersVisible:(BOOL)bothVisible;
- (void)setCellIndexPath:(NSIndexPath *)cellIndexPath;
- (void)setContent:(NSString *)content withPoints:(NSInteger)points postTime:(NSTimeInterval)postTime numberOfReplies:(NSInteger)replies groups:(NSArray *)groups nonHighlightedGroupIndexes:(NSArray *)nonHighlightedGroupIndexes;
- (void)setUpCell;
- (void)setVoteChangedBlock:(void (^)(MCVoteViewState, NSIndexPath *))voteChangedBlock;

@end
