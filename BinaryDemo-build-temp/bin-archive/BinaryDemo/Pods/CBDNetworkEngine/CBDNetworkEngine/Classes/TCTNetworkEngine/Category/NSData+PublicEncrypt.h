//
//  NSData+PublicEncrypt.h
//  TCTNetworkEngine
//
//  Created by maxfong on 15-01-01.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const kCBDCommonKey;
extern NSString * const kCBDRequestKey;

@interface NSData (PublicEncrypt)

- (NSString *)base64;
- (NSData*)AES128EncryptWithKey:(NSString*)key initVector:(NSData*)iv;
- (NSData*)AES128DecryptWithKey:(NSString*)key initVector:(NSData*)iv;

+ (NSData *)cbd_AES128EncryptByCBD:(NSData*)data withKey:(NSString *)key;
+ (NSData *)cbd_AES128DecryptByCBD:(NSData*)data withKey:(NSString *)key;

@end
