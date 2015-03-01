//
//  MCPostTableView.h
//  micmac
//
//  Created by Bryce Pauken on 2/17/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPostTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

- (void)endRefresh;
- (void)setPosts:(NSArray *)posts;
- (void)setRefreshStarted:(void (^)())refreshStarted;

@end
