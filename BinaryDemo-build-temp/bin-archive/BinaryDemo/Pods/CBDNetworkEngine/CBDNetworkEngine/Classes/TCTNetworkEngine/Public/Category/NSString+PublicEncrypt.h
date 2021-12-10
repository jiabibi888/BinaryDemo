//
//  NSString+PublicEncrypt.h
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const kCBDCommonKey;
extern NSString * const kCBDRequestKey;

@interface NSString (PublicEncrypt)

/** MD5 */
- (NSString *)md5;

/** base64 */
- (NSString *)base64;
- (NSData *)decodeBase64;

/** aes加密后转换base64，使用TCT默认Key */
- (NSString *)aesEncryptAndBase64Encode;
/** 转换base64并解密aes，使用TCT默认Key */
- (NSString *)aesDecryptAndBase64Decode;

+ (NSString *)aesEncryptAndBase64Encode:(NSString*)string;
+ (NSString *)cbd_aesEncryptAndBase64EncodeByCBD:(NSString*)string withKey:(NSString *)key;
+ (NSString *)aesDecryptAndBase64Decode:(NSString*)string;
+ (NSString *)cbd_aesDecryptAndBase64DecodeByCBD:(NSString*)string withKey:(NSString *)key;

@end
