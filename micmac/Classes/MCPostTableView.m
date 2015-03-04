//
//  MCPostTableView.m
//  micmac
//
//  Created by Bryce Pauken on 2/17/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPostTableView.h"

#import "MCActivityIndicatorView.h"
#import "MCAPIHandler.h"
#import "MCPostCell.h"

@interface MCPostTableView()

@property (nonatomic, strong) UITableViewController *controller;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, copy) void (^postsUpdated)(NSArray *posts);
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, copy) void (^refreshStarted)();

@end

@implementation MCPostTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _controller = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        [_controller setTableView:self];
        
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [_controller setRefreshControl:_refreshControl];
        
        [self registerClass:[MCPostCell class] forCellReuseIdentifier:@"MCPostCell"];
        [self setBackgroundColor:[UIColor MCOffWhiteColor]];
        [self setDataSource:self];
        [self setDelegate:self];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return self;
}

- (void)endRefresh {
    [self.refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)refresh {
    if(self.refreshStarted) {
        self.refreshStarted();
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (void)setPosts:(NSArray *)posts {
    if(posts && ![posts isEqual:[NSNull null]] && posts.count) {
        NSMutableArray *mutablePosts = [[NSMutableArray alloc] initWithCapacity:posts.count];
        for(NSDictionary *post in posts) {
            [mutablePosts addObject:[post mutableCopy]];
        }
        _posts = mutablePosts;
    }
    
    [self reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCPostCell"];
    if(!cell) {
        cell = [[MCPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MCPostCell"];
    }
    if(![cell initialized]) {
        __weak MCPostTableView *weakSelf = self;
        [cell setUpCell];
        [cell setVoteChangedBlock:^(MCVoteViewState state, NSIndexPath *cellIndexPath) {
            [weakSelf voteViewStateChanged:state forIndexPath:cellIndexPath];
        }];
    }
    
    NSDictionary *post = [self.posts objectAtIndex:indexPath.row];
    [cell setBothDivividersVisible:indexPath.row==0];
    [cell setCellIndexPath:indexPath];
    [cell setContent:[post objectForKey:@"post"] withPoints:[[post objectForKey:@"points"] integerValue] vote:[[post objectForKey:@"vote"] integerValue] postTime:[[post objectForKey:@"time"] doubleValue] numberOfReplies:0 groups:nil nonHighlightedGroupIndexes:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *post = [self.posts objectAtIndex:indexPath.row];
    return [MCPostCell heightForCellOfWidth:tableView.frame.size.width withText:[post objectForKey:@"post"] showGroups:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.posts&&![self.posts isEqual:[NSNull null]])?self.posts.count:0;
}

- (void)voteViewStateChanged:(MCVoteViewState)state forIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *post = [self.posts objectAtIndex:indexPath.row];
    
    NSString *voteString;
    switch(state) {
        case MCVoteViewStateUpVoted:
            voteString = @"up";
            break;
        case MCVoteViewStateDownVoted:
            voteString = @"down";
            break;
        default:
            voteString = @"none";
            break;
    }
    [MCAPIHandler makeRequestToFunction:@"Vote" components:@[[post objectForKey:@"id"], voteString] parameters:nil completion:nil];
    
    //update local values
    MCVoteViewState previousState = [[post objectForKey:@"vote"] integerValue];
    [post setObject:@(state) forKey:@"vote"];
    
    if(previousState == MCVoteViewStateDownVoted) {
        previousState = -1;
    }
    if(state == MCVoteViewStateDownVoted) {
        state = -1;
    }
    
    [post setObject:@([[post objectForKey:@"points"] integerValue]+(state-previousState)) forKey:@"points"];
    
    if(self.postsUpdated) {
        self.postsUpdated(self.posts);
    }
}

@end
