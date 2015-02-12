//
//  MCAPIHandler.h
//  micmac
//
//  Created by Bryce Pauken on 2/4/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCAPIHandler : NSObject

+ (void)makeRequestToFunction:(NSString *)function components:(NSArray *)components parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *data))completion;

@end
