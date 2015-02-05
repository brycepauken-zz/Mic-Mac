//
//  MCSettingsManager.h
//  micmac
//
//  Created by Bryce Pauken on 2/4/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCSettingsManager : NSObject

+ (void)setSetting:(id)setting forKey:(id<NSCopying>)key;
+ (id)settingForKey:(id<NSCopying>)key;

@end
