//
//  MCVoteView.h
//  micmac
//
//  Created by Bryce Pauken on 2/21/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MCVoteViewState) {
    MCVoteViewStateDefault = 0,
    MCVoteViewStateUpVoted = 1,
    MCVoteViewStateDownVoted = 2
};

@interface MCVoteView : UIView <UIGestureRecognizerDelegate>

- (void)setPoints:(NSInteger)points;
- (void)setVoteChangedBlock:(void (^)(MCVoteViewState))voteChangedBlock;
- (void)setVoteState:(MCVoteViewState)voteState;

@end
