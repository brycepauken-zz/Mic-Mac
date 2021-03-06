//
//  MCGroupSelectionView.h
//  micmac
//
//  Created by Bryce Pauken on 2/24/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCGroupSelectionView : UIScrollView <UIScrollViewDelegate>

- (NSArray *)groups;
- (NSArray *)selectedIndexes;
- (void)setGroups:(NSArray *)groups;
- (void)setSelectionChanged:(void (^)())selectionChanged;

@end
