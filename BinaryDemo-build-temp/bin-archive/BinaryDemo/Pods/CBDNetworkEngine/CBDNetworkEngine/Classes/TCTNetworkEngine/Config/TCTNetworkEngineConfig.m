//
//  TCTNetworkEngineConfig.m
//  CarBaDa
//
//  Created by Jabir-Zhang on 2021/1/29.
//  Copyright © 2021 wyj. All rights reserved.
//

#import "TCTNetworkEngineConfig.h"
#import "NSString+NetworkEngineEncrypt.h"
#import "TCTHTTPRequestOperationManager.h"

static TCTNetworkEngineConfig * _instance = nil;

static NSString * const kCarBaDa_RefId = @"94955307";

@interface TCTNetworkEngineConfig ()
@property (nonatomic, copy) NSString *sSessionId;
@property (nonatomic, copy) NSString *sSecurity;
@end

@implementation TCTNetworkEngineConfig
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
        BOOL isDebug = NO;
    #ifdef DEBUGMODEL
        isDebug = YES;
    #endif
        _instance.networkDebug = [[TCTNetworkDebug alloc] init];
        [_instance.networkDebug setDebug:isDebug];
        [_instance.networkDebug setLogRequest:isDebug];
        [_instance.networkDebug setLogResponse:isDebug];
        
        _instance.protocolEngine = [TCTProtocolEngine startWithBuilder:^(TCTNetworkEncrypt *encrypt) {
            encrypt.type = TCTNetworkEncrypt_AES;
            encrypt.clientType = @"iPhone";
            encrypt.clientVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            encrypt.protocolVer = @"20150526020002";
            encrypt.accountID = @"d4a45219-f2f2-4a2a-ab7b-007ee848629d";
            encrypt.digitalSignPrivateKey = @"61868BB6EA1F46FAA3C10AD4BEE2F6D4";
            encrypt.reqDataKey = @"6847E4D3-1A6B-4AA5-B504-15B1A7C01490";
            encrypt.rspDataKey = @"51F90A3C-CF56-4CC4-A0DD-D5CE453968AE";
            encrypt.reqBodyAESKey = kCBDRequestKey;
            encrypt.rspBodyAESKey = kCBDRequestKey;
            encrypt.rspDataDisabledKey = @"6582C6E4-738F-46B2-8F4A-C83CD6D7C70F";
        }];
    }) ;
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [TCTNetworkEngineConfig shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [TCTNetworkEngineConfig shareInstance];
}

+ (NSString *)networkConfit_TCTNetworkEngine_Audio_Refid {
    return kCarBaDa_RefId;
}

+ (NSString *)networkConfit_TCTNetworkEngine_DevicePushToken {
    return @"";
}

+ (NSString *)networkConfit_TCTNetworkEngine_TagValue {
    return @"";
}

+ (NSString *)networkConfit_TCTNetworkEngine_KeyChain_Key {
    return @"";
}

+ (NSString *)cbdSessionId {
    if (![TCTNetworkEngineConfig shareInstance].sSessionId) {
        [TCTNetworkEngineConfig shareInstance].sSessionId = [NSUUID UUID].UUIDString;
    }
    return [TCTNetworkEngineConfig shareInstance].sSessionId;
}

+ (void)reloadCBDSessionId {
    [TCTNetworkEngineConfig shareInstance].sSessionId = [NSUUID UUID].UUIDString;
}

+ (void)setCBDSecurity:(NSString *)sSecurity {
    [TCTNetworkEngineConfig shareInstance].sSecurity = sSecurity;
}

+ (NSString *)cbdSecurity {
    return [TCTNetworkEngineConfig shareInstance].sSecurity;
}

+ (void)cbdClearResponseDataCache {
    [[TCTHTTPRequestOperationManager manager]  clearResponseDataCache];
}

@end
