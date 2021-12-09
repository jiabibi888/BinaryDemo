//
//  NSString+NetworkEngineEncrypt.m
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-8.
//
//

#import "NSString+NetworkEngineEncrypt.h"
#import "CommonCrypto/CommonDigest.h"
#import "NSData-AES.h"
#import "tc_GTMBase64.h"

NSString * const kCBDCommonKey = @"j7Eb526F0^_^0g4F";
NSString * const kCBDRequestKey = @"EF290D911DD34E8E";

static const unsigned char AES_IV[] =
{ 0x54, 0x43, 0x4D, 0x6F, 0x62, 0x69, 0x6C, 0x65, 0x5B, 0x41, 0x45, 0x53, 0x5F, 0x49, 0x56, 0x5D };

static const unsigned char AES_IV_CBD[] =
{ 0x13, 0x33, 0x5D, 0x7F, 0x52, 0x29, 0x2C, 0x15, 0x3B, 0x51, 0x55, 0x23, 0x4F, 0x19, 0x36, 0x3D };//加密需要的向量


@implementation NSString (NetworkEngineEncrypt)

- (NSString *)tc_MD5EncodedString {
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

- (NSString *)tc_base64EncodedString {
    return [tc_GTMBase64 stringByEncodingData:[self dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData *)tc_base64DecodedString {
    return [tc_GTMBase64 decodeString:self];
}

#pragma mark - AES
- (NSString *)tc_aesEncryptAndBase64EncodeWithKey:(NSString *)key {
    return [NSString tc_aesEncryptAndBase64Encode:self withKey:key];
}

- (NSString *)tc_aesDecryptAndBase64DecodeWithKey:(NSString *)key {
    return [NSString tc_aesDecryptAndBase64Decode:self withKey:key];
}

+ (NSString *)tc_aesEncryptAndBase64Encode:(NSString*)string withKey:(NSString *)key {
    if ([string length] <= 0 || [key length] <= 0) return nil;
    
    NSString *secret = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *iv = [NSData dataWithBytes:AES_IV length:sizeof(AES_IV)];
    NSData *encrypt = [data tc_AES128EncryptWithKey:key initVector:iv];
    if (encrypt) secret = [tc_GTMBase64 stringByEncodingData:encrypt];
    return [secret stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

+ (NSString *)tc_aesEncryptAndBase64EncodeByCBD:(NSString*)string withKey:(NSString *)key {
    if ([string length] <= 0 || [key length] <= 0) return nil;
    
    NSString *secret = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *iv = [NSData dataWithBytes:AES_IV_CBD length:sizeof(AES_IV_CBD)];
    NSData *encrypt = [data tc_AES128EncryptWithKey:key initVector:iv];
    if (encrypt) secret = [tc_GTMBase64 stringByEncodingData:encrypt];
    return secret;
}

+ (NSData *)tc_aesEncryptAndBase64EncodeDataByCBD:(NSData*)data withKey:(NSString *)key {
    if ([data length] <= 0 || [key length] <= 0) return nil;
    NSData *iv = [NSData dataWithBytes:AES_IV_CBD length:sizeof(AES_IV_CBD)];
    NSData *encrypt = [data tc_AES128EncryptWithKey:key initVector:iv];
    return encrypt;
}


+ (NSString *)tc_aesDecryptAndBase64Decode:(NSString*)string withKey:(NSString *)key {
    if ([string length] <= 0 || [key length] <= 0) return nil;
    
    NSString *secret = nil;
    NSData *data = [tc_GTMBase64 decodeString:string];
    NSData *iv = [NSData dataWithBytes:AES_IV length:sizeof(AES_IV)];
    NSData *decrypt = [data tc_AES128DecryptWithKey:key initVector:iv];
    if (decrypt) secret = [[NSString alloc] initWithData:decrypt encoding:NSUTF8StringEncoding];
    return secret;
}

+ (NSString *)tc_aesDecryptAndBase64DecodeByCBD:(NSString*)string withKey:(NSString *)key {
    if ([string length] <= 0 || [key length] <= 0) return nil;
    
    NSString *secret = nil;
    NSData *data = [tc_GTMBase64 decodeString:string];
    NSData *iv = [NSData dataWithBytes:AES_IV_CBD length:sizeof(AES_IV_CBD)];
    NSData *decrypt = [data tc_AES128DecryptWithKey:key initVector:iv];
    if (decrypt) secret = [[NSString alloc] initWithData:decrypt encoding:NSUTF8StringEncoding];
    return secret;
}

+ (NSData *)tc_aesDecryptAndBase64DecodeDataByCBD:(NSData*)data withKey:(NSString *)key {
    if ([data length] <= 0 || [key length] <= 0) return nil;
    
//    NSData *data = [tc_GTMBase64 decodeString:string];
    NSData *iv = [NSData dataWithBytes:AES_IV_CBD length:sizeof(AES_IV_CBD)];
    NSData *decrypt = [data tc_AES128DecryptWithKey:key initVector:iv];
    return decrypt;
}

@end
