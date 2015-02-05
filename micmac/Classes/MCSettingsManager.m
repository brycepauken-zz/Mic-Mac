//
//  MCSettingsManager.m
//  micmac
//
//  Created by Bryce Pauken on 2/4/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCSettingsManager.h"

#import <Security/Security.h>

@implementation MCSettingsManager

static NSString const *_kBundleIdentifier = @"com.kingfish.micmac-beta";
static NSString const *_kKeychainIdentifier = @"MCSettings";
static NSMutableDictionary *_settings;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(![self settings]) {
            _settings = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"username", [[NSString stringWithFormat:@"%f%d",[[NSDate date] timeIntervalSince1970],arc4random_uniform(UINT32_MAX)] md5],@"password", nil];
            [self createSettings];
        }
    });
}

+ (BOOL)createSettings {
    NSMutableDictionary *dictionary = [self searchDictionary];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:_settings options:0 error:nil];
    [dictionary setObject:data forKey:(__bridge id)kSecValueData];
    
    return SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL) == errSecSuccess;
}

+ (NSMutableDictionary *)searchDictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSData *keychainID = [_kKeychainIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    
    [dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [dictionary setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
    [dictionary setObject:keychainID forKey:(__bridge id)kSecAttrAccount];
    [dictionary setObject:_kBundleIdentifier forKey:(__bridge id)kSecAttrService];
    
    return dictionary;
}

+ (void)setSetting:(id)setting forKey:(id<NSCopying>)key {
    [[self settings] setObject:setting forKey:key];
}

+ (id)settingForKey:(id<NSCopying>)key {
    return [[self settings] objectForKey:key];
}

+ (NSMutableDictionary *)settings {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *dictionary = [self searchDictionary];
        
        [dictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [dictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        
        NSData *data = NULL;
        CFTypeRef dataTypeRef = (__bridge CFTypeRef)data;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)dictionary, &dataTypeRef);
        data = (__bridge NSData *)dataTypeRef;
        if(status == errSecSuccess && data) {
            _settings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        }
    });
    return _settings;
}

+ (BOOL)updateSettings {
    NSMutableDictionary *searchDictionary = [self searchDictionary];
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:_settings options:0 error:&error];
    if(!error) {
        [newDictionary setObject:data forKey:(__bridge id)kSecValueData];
        return SecItemUpdate((__bridge CFDictionaryRef)searchDictionary, (__bridge CFDictionaryRef)newDictionary)==errSecSuccess;
    }
    return NO;
}

@end
