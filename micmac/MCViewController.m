//
//  ViewController.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCViewController.h"

#import "MCMainView.h"

@interface MCViewController ()

@property (nonatomic, strong) MCMainView *mainView;

@end

@implementation MCViewController

- (instancetype)init {
    self = [super init];
    if(self) {
        _mainView = [[MCMainView alloc] initWithFrame:self.view.bounds];
        [_mainView setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [self.view addSubview:_mainView];
        
        [self setNeedsStatusBarAppearanceUpdate];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
