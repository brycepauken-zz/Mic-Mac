//
//  MCAPIHandler.m
//  micmac
//
//  Created by Bryce Pauken on 2/4/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCAPIHandler.h"

#import "MCSettingsManager.h"

@implementation MCAPIHandler

/*
 Make a request to the API.
 For example, [MCAPIHandler makeRequestToFunction:@"a" components:@[@"b",@"c"] parameters:@{@"d"=>@"e"}
 will make a request to /api/v1/a/b/c?d=e (with the parameters sent as POST).
 */
+ (id)makeRequestToFunction:(NSString *)function components:(NSArray *)components parameters:(NSDictionary *)parameters {
    NSString *username = [MCSettingsManager settingForKey:@"username"]?:@"";
    NSString *password = [MCSettingsManager settingForKey:@"password"]?:@"";
    
    NSString *requestString = [NSString stringWithFormat:@"http://micmac.kingfi.sh/api/v1/%@/%@",function,[components componentsJoinedByString:@"/"]];
    NSString *randomChars = [[[NSString stringWithFormat:@"%f%d",[[NSDate date] timeIntervalSince1970],arc4random_uniform(UINT32_MAX)] md5] substringToIndex:16];
    NSString *requestMD5 = [[NSString stringWithFormat:@"%@%@%@%@",requestString,username,password,randomChars] md5];
    
    int customHash=0, i=0, o=0;
    int charVal = [requestMD5 characterAtIndex:0];
    while(i<(charVal>65?charVal:65) && i<512) {
        customHash += (charVal<<((charVal+i)%8));
        o += charVal&15;
        charVal = [requestMD5 characterAtIndex:(i+o)%requestMD5.length];
        if(++i == charVal) {
            i = i<<1;
        }
    }
    
    NSString *customHashMD5 = [[[NSString stringWithFormat:@"%d",customHash] md5] substringToIndex:16];
    NSString *authToken = [customHashMD5 stringByAppendingString:randomChars];
    
    authToken = nil;
    //to be implemented
    
    return nil;
}

@end