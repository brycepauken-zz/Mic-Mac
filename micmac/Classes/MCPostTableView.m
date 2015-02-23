//
//  MCPostTableView.m
//  micmac
//
//  Created by Bryce Pauken on 2/17/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCPostTableView.h"

#import "MCPostCell.h"

@interface MCPostTableView()

@property (nonatomic, strong) NSArray *posts;

@end

@implementation MCPostTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self registerClass:[MCPostCell class] forCellReuseIdentifier:@"MCPostCell"];
        [self setBackgroundColor:[UIColor MCOffWhiteColor]];
        [self setDataSource:self];
        [self setDelegate:self];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (void)setPosts:(NSArray *)posts {
    _posts = posts;
    [self reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCPostCell"];
    if(!cell) {
        cell = [[MCPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MCPostCell"];
    }
    if(![cell initialized]) {
        [cell setUpCell];
    }
    
    NSDictionary *post = [self.posts objectAtIndex:indexPath.row];
    [cell setBothDivividersVisible:indexPath.row==0];
    [cell setContent:[post objectForKey:@"post"] withPoints:[[post objectForKey:@"points"] integerValue]];
    
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
    return [MCPostCell heightForCellOfWidth:tableView.frame.size.width withText:[post objectForKey:@"post"] points:[[post objectForKey:@"points"] integerValue]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

@end
