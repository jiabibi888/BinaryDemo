//
//  TCTKeyChain.m
//  TCTNetworkEngine
//
//  Created by maxfong on 15-01-01.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTKeyChain.h"
#import "TCFoundation.h"

@implementation TCTKeyChain

+ (NSMutableDictionary *)keyChainQuery:(NSString *)key {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,
            key, (__bridge id)kSecAttrService,
            key, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,
            nil];
}

+ (void)setObject:(id)anObject forKey:(NSString*)key {
    //Get search dictionary
    NSMutableDictionary *keyChainQuery = [self keyChainQuery:key];
    //Delete old item before add new item
    SecItemDelete((__bridge CFDictionaryRef)keyChainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keyChainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:anObject] forKey:(__bridge id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge CFDictionaryRef)keyChainQuery, NULL);
}

+ (id)objectForKey:(NSString *)key {
    id object = nil;
    NSMutableDictionary *keyChainQuery = [self keyChainQuery:key];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keyChainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keyChainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keyChainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSDebugLog(@"Unarchive of %@ failed: %@", key, e);
        } @finally { }
    }
    if (keyData) CFRelease(keyData);
    return object;
}

+ (void)removeObjectForKey:(NSString *)key {
    NSMutableDictionary *keyChainQuery = [self keyChainQuery:key];
    SecItemDelete((__bridge CFDictionaryRef)keyChainQuery);
}


@end
