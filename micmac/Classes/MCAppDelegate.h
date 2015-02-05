//
//  AppDelegate.h
//  micmac
//
//  Created by Bryce Pauken on 12/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MCMainView;

@interface MCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (MCMainView *)mainView;

@end

