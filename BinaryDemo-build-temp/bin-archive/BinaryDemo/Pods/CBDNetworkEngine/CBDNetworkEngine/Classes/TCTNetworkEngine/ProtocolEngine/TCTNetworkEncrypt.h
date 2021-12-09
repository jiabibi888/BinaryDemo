//
//  TCTNetworkEncrypt.h
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TCTNetworkEncryptType) {
    TCTNetworkEncrypt_None      = 0,    //无任何加密：iPad 1.0
    TCTNetworkEncrypt_Req,              //对request的HTTP加密，需要reqDataKey
    TCTNetworkEncrypt_AES       = 4,    //对request&response的body&HTTP进行AES加密解密，需要reqDataKey、reqBodyAESKey、rspDataKey、rspBodyAESKey
    TCTNetworkEncrypt_AES_UnBody= 3     //对request&response的HTTP进行AES加密解密，需要reqDataKey、rspDataKey
};

@interface TCTNetworkEncrypt : NSObject

/** 当前客户端版本 */
@property (nonatomic, strong) NSString *clientVersion;
/** 当前客户端类型、VersionType */
@property (nonatomic, strong) NSString *clientType;
/** 当前App在中间层注册的版本 */
@property (nonatomic, strong) NSString *protocolVer;
/** 当前App在中间层注册的账户ID(accountID) */
@property (nonatomic, strong) NSString *accountID;
/** 当前App在中间层注册的账户Key(accountKey) */
@property (nonatomic, strong) NSString *digitalSignPrivateKey;  //accountKey

/** request中reqdata值的加密Key 
 请求数据 -> Http Header -> 添加reqdata字段,值为Http body全文+reqDataKey 后执行MD5操作 */
@property (nonatomic, strong) NSString *reqDataKey;
/** request的Body加密Key
 请求数据 body字段全文AES加密，密钥为reqBodyAESKey，加密后Base64处理 */
@property (nonatomic, strong) NSString *reqBodyAESKey;
/** response中reqdata值的加密Key
 响应数据 -> Http Header -> 添加reqdata字段，值为Http body全文+rspDataKey 后执行MD5操作 */
@property (nonatomic, strong) NSString *rspDataKey;
/** response的Body加密Key 
 响应数据 body字段全文AES加密，密钥为rspBodyAESKey，加密后Base64处理 */
@property (nonatomic, strong) NSString *rspBodyAESKey;

/** 使response无需解密，对响应数据不执行sec-ver和reqdata签名校验 */
@property (nonatomic, strong) NSString *rspDataDisabledKey;

/** 加密类型 */
@property (nonatomic, assign) TCTNetworkEncryptType type;

@end
