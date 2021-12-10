//
//  NSString+NetworkEngineEncrypt.h
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-8.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kCBDCommonKey;
extern NSString * const kCBDRequestKey;

@interface NSString (NetworkEngineEncrypt)

/** 获取MD5 */
- (NSString *)tc_MD5EncodedString;

/** 获取base64 */
- (NSString *)tc_base64EncodedString;
- (NSData *)tc_base64DecodedString;

/** aes加密后转换base64 */
- (NSString *)tc_aesEncryptAndBase64EncodeWithKey:(NSString *)key;
/** 转换base64并解密aes */
- (NSString *)tc_aesDecryptAndBase64DecodeWithKey:(NSString *)key;

+ (NSString *)tc_aesEncryptAndBase64Encode:(NSString*)string withKey:(NSString *)key;
+ (NSString *)tc_aesEncryptAndBase64EncodeByCBD:(NSString*)string withKey:(NSString *)key;
+ (NSString *)tc_aesDecryptAndBase64Decode:(NSString*)string withKey:(NSString *)key;
+ (NSString *)tc_aesDecryptAndBase64DecodeByCBD:(NSString*)string withKey:(NSString *)key;

+ (NSData *)tc_aesEncryptAndBase64EncodeDataByCBD:(NSData*)data withKey:(NSString *)key;
+ (NSData *)tc_aesDecryptAndBase64DecodeDataByCBD:(NSData*)data withKey:(NSString *)key;

@end
