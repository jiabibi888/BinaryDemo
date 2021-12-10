//
//  NSData+PublicEncrypt.m
//  TCTNetworkEngine
//
//  Created by maxfong on 15-01-01.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "NSData+PublicEncrypt.h"
#import "NSData-AES.h"
#import "NSString+NetworkEngineEncrypt.h"

@implementation NSData (PublicEncrypt)

- (NSString *)base64 {
    return [self tc_base64EncodedString];
}
- (NSData*)AES128EncryptWithKey:(NSString*)key initVector:(NSData*)iv {
    return [self tc_AES128EncryptWithKey:key initVector:iv];
}
- (NSData*)AES128DecryptWithKey:(NSString*)key initVector:(NSData*)iv {
    return [self tc_AES128DecryptWithKey:key initVector:iv];
}

+ (NSData *)cbd_AES128EncryptByCBD:(NSData*)data withKey:(NSString *)key {
    return [NSString tc_aesEncryptAndBase64EncodeDataByCBD:data withKey:key];
}

+ (NSData *)cbd_AES128DecryptByCBD:(NSData*)data withKey:(NSString *)key {
    return [NSString tc_aesDecryptAndBase64DecodeDataByCBD:data withKey:key];
}

@end
