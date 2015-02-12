//
//  MCMainView.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCMainView.h"

#import "MCPageView.h"
#import "MCSettingsManager.h"
#import "MCStartView.h"
#import "MCTabView.h"

@interface MCMainView()

@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) MCStartView *startView;
@property (nonatomic, strong) MCTabView *tabView;

@end

@implementation MCMainView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        __weak MCMainView *weakSelf = self;
        
        if(![[MCSettingsManager settingForKey:@"starupCompleted"] boolValue]) {
            _startView = [[MCStartView alloc] initWithFrame:self.bounds];
            [_startView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
            [_startView setHiddenBlock:^{
                [weakSelf unsetStartView];
            }];
        }
        
        NSArray *pageNames = @[@"Macro", @"Micro", @"Me", @"More"];
        _pages = [[NSMutableArray alloc] init];
        __weak NSArray *weakPages = _pages;
        for(int i=0;i<pageNames.count;i++) {
            MCPageView *page = [[MCPageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-50) name:[pageNames objectAtIndex:i]];
            [page setHidden:i!=1];
            [_pages addObject:page];
            [self addSubview:page];
        }
        
        _tabView = [[MCTabView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-60, self.bounds.size.width, 60)];
        [_tabView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [_tabView setButtonTapped:^(int index) {
            for(int i=0;i<weakPages.count;i++) {
                [[weakPages objectAtIndex:i] setHidden:i!=index];
            }
        }];
        
        [self setBackgroundColor:[UIColor MCOffWhiteColor]];
        [self addSubview:_tabView];
        if(_startView) {
            [self addSubview:_startView];
        }
    }
    return self;
}

- (void)layoutSubviews {
    CGRect pageFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-50);
    for(MCPageView *page in self.pages) {
        [page setFrame:pageFrame];
    }
}

- (void)unsetStartView {
    [self.startView removeFromSuperview];
    self.startView = nil;
}

@end
