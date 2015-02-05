//
//  AppDelegate.m
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "MCAppDelegate.h"

#import "MCViewController.h"

@interface MCAppDelegate ()

@property (nonatomic, strong) MCViewController *viewController;

@end

@implementation MCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //seed random number generator
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        srand48(time(0));
    });
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor blackColor]];
    [self.window setClipsToBounds:YES];
    
    self.viewController = [[MCViewController alloc] init];
    [self.window setRootViewController:self.viewController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (MCMainView *)mainView {
    return self.viewController.mainView;
}

@end
