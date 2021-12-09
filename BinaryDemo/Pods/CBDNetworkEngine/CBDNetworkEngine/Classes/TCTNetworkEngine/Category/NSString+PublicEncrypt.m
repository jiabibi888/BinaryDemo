//
//  NSString+PublicEncrypt.m
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "NSString+PublicEncrypt.h"
#import "NSString+NetworkEngineEncrypt.h"

static NSString *TCTDefaultAESKey = @"TongCheng.Mobile";

@implementation NSString (PublicEncrypt)

- (NSString *)md5 {
    return [self tc_MD5EncodedString];
}

- (NSString *)base64 {
    return [self tc_base64EncodedString];
}

- (NSData *)decodeBase64 {
    return [self tc_base64DecodedString];
}

- (NSString *)aesEncryptAndBase64Encode {
    return [self tc_aesEncryptAndBase64EncodeWithKey:TCTDefaultAESKey];
}

- (NSString *)aesDecryptAndBase64Decode {
    return [self tc_aesDecryptAndBase64DecodeWithKey:TCTDefaultAESKey];
}

+ (NSString *)aesEncryptAndBase64Encode:(NSString*)string {
    return [self tc_aesEncryptAndBase64Encode:string withKey:TCTDefaultAESKey];
}

+ (NSString *)cbd_aesEncryptAndBase64EncodeByCBD:(NSString*)string withKey:(NSString *)key {
    return [self tc_aesEncryptAndBase64EncodeByCBD:string withKey:key];
}

+ (NSString *)aesDecryptAndBase64Decode:(NSString*)string {
    return [self tc_aesDecryptAndBase64Decode:string withKey:TCTDefaultAESKey];
}

+ (NSString *)cbd_aesDecryptAndBase64DecodeByCBD:(NSString*)string withKey:(NSString *)key {
    return [self tc_aesDecryptAndBase64DecodeByCBD:string withKey:key];
}

@end
