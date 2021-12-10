//
//  TCTRequestObject+Encrypt.m
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <UIKit/UIDevice.h>
#import "TCTRequestObject+Encrypt.h"
#import "NSString+NetworkEngineEncrypt.h"
#import "NSString+NetworkEngineReplace.h"
#import "NSObject+NetworkEngineParse.h"
#import "TCTNetworkEncrypt+Handle.h"
#import "TCTIdentifier.h"
#import "sys/utsname.h"
#import "TCTNetworkEngineConfig.h"
#import "TCFoundation.h"

@implementation TCTRequestObject (Encrypt)

- (TCTProtocolEngine *)protocolEngine
{
    TCTProtocolEngine *engine = [TCTNetworkEngineConfig shareInstance].protocolEngine;
    return engine;
}

- (NSString *)requestEncryptKey
{
    NSMutableDictionary *propertyValueDictionary = [self propertyValueDictionary];
    if (propertyValueDictionary) {
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:propertyValueDictionary
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        if ([JSONData length] > 0) {
            NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
            NSString *digitalSign = [NSString stringWithFormat:@"m%@a%@x", [self interfaceURL], [self serviceName]];
            
            return [[NSString stringWithFormat:@"%@%@", JSONString, digitalSign] tc_MD5EncodedString];
        }
    }
    return nil;
}

- (NSMutableDictionary *)propertyValueDictionary
{
    NSMutableDictionary *propertyValueDictionary = nil;
    if ([self respondsToSelector:@selector(ownParamsDictionary)]) {
        propertyValueDictionary = [[self ownParamsDictionary] mutableCopy];
    }
    if (!propertyValueDictionary && [self respondsToSelector:@selector(tc_propertyDictionary)]) {
        propertyValueDictionary = [self performSelector:@selector(tc_propertyDictionary)];
    }
    return propertyValueDictionary;
}

//20151120 Jabir 请求加密修改
- (NSString *)requestJSONStringWithEncrypt:(TCTNetworkEncrypt *)encrypt
{
    if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
        NSAssert([self serviceName] != nil, @"TCTNetworkEngine Tip:request对象serviceName未设置");
    }
    
    NSDictionary *clientInfo = [self clientInfoDictionaryWithEncrypt:encrypt] ?: @{};
    
    NSMutableDictionary *bodyDictionary = [self propertyValueDictionary];
    
    //20150215 body AES加密
    NSUInteger deltaTime = 0;
    id bodyEncrypt = @"";
    //隐藏功能，请求自定义加密类型
    TCTNetworkEncryptType encryptType = encrypt.type;
    if ([self respondsToSelector:@selector(ownEncryptType)]) {
        encryptType = [self ownEncryptType];
    }
    
    NSDictionary *headerDictionary = [self headDictionaryWithServiceName:[self serviceName] withEncryptEffort:@(deltaTime).stringValue withEncrypt:encrypt];
    bodyEncrypt = bodyDictionary;
    NSDictionary *requestDictionary =@{@"header": headerDictionary, @"body": bodyEncrypt, @"clientInfo":clientInfo};
    NSError *error = nil;
    NSString *requestJSONString = nil;
    NSString *tempRequestJSONString = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:requestDictionary
                                                       options:0
                                                         error:&error];
    if (JSONData) {
        tempRequestJSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
//        //20150306fix aes加密方式产生的反斜杠需要移除,而其他项目需要指定参数
//        tempRequestJSONString = [[[tempRequestJSONString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"☻"]
//                              stringByReplacingOccurrencesOfString:@"\\" withString:@""]
//                             stringByReplacingOccurrencesOfString:@"☻" withString:@"\\\""];
    }
    
    switch (encryptType) {
        case TCTNetworkEncrypt_None:
        case TCTNetworkEncrypt_Req:
        case TCTNetworkEncrypt_AES_UnBody:
        {
            requestJSONString = tempRequestJSONString;
        }
            break;
        case TCTNetworkEncrypt_AES:
        {
            NSDate *startData = [NSDate date];
            if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
                NSAssert(error == nil, @"TCTNetworkEngine Tip:%@", [error localizedDescription]);
            }
            if (!error) {
                requestJSONString = [NSString tc_aesEncryptAndBase64EncodeByCBD:tempRequestJSONString withKey:encrypt.reqBodyAESKey];
                if (requestJSONString) {
                    //20150306fix aes加密方式产生的反斜杠需要移除,而其他项目需要指定参数
                    requestJSONString = [[[requestJSONString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"☻"]
                                          stringByReplacingOccurrencesOfString:@"\\" withString:@""]
                                         stringByReplacingOccurrencesOfString:@"☻" withString:@"\\\""];
                }
            }
            deltaTime = [[NSDate date] timeIntervalSinceDate:startData] * 1000;
        }
            break;
        default: break;
    }
    
    
    
    
    
    if ([[TCTNetworkEngineConfig shareInstance].networkDebug isLogRequest]) {
        NSString *debug_requestJSONString = nil;
        switch (encryptType) {
            case TCTNetworkEncrypt_None:
            case TCTNetworkEncrypt_Req:
            case TCTNetworkEncrypt_AES_UnBody:
            {
                debug_requestJSONString = requestJSONString;
            }
                break;
            case TCTNetworkEncrypt_AES:
            {
//                NSDictionary *debug_requestDictionary = @{@"request": @{@"encrypt": requestJSONString,@"header": headerDictionary, @"body": bodyDictionary,@"clientInfo":clientInfo}};
                NSDictionary *debug_requestDictionary = @{@"request": @{@"header": headerDictionary, @"body": bodyDictionary,@"clientInfo":clientInfo}};
                NSData *debug_JSONData = [NSJSONSerialization dataWithJSONObject:debug_requestDictionary
                                                                         options:0
                                                                           error:&error];
                if (debug_JSONData) {
                    debug_requestJSONString = [[NSString alloc] initWithData:debug_JSONData encoding:NSUTF8StringEncoding];
                    //AES加密方式产生的反斜杠需要移除,而其他项目需要指定参数
                    debug_requestJSONString = [[[debug_requestJSONString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"☻"]
                                          stringByReplacingOccurrencesOfString:@"\\" withString:@""]
                                         stringByReplacingOccurrencesOfString:@"☻" withString:@"\\\""];
                }
            }
                break;
            default: break;
        }
        [self logRequestJson:debug_requestJSONString];

    }
    return requestJSONString;
}

- (void)logRequestJson:(NSString *)requestJSONString{
     requestJSONString = [[[[[[requestJSONString stringByReplacingOccurrencesOfString:@",\"" withString:@", \\\n            \""]
                        stringByReplacingOccurrencesOfString:@"{" withString:@"{\\\n            "]
                       stringByReplacingOccurrencesOfString:@"}," withString:@"\\\n},"]
                      stringByReplacingOccurrencesOfString:@"}}}" withString:@"\\\n        }\\\n    }\\\n}\\\n"]
                    stringByReplacingOccurrencesOfString:@"}," withString:@"           },"]
                     stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    
    if ([requestJSONString containsString:@"         \"request\":{"]) {
        requestJSONString =  [requestJSONString stringByReplacingOccurrencesOfString:@"         \"request\":{"  withString:@"    \"request\":{"];
    }
    
    if ([requestJSONString containsString:@"            \"header\":{"]) {
        requestJSONString =  [requestJSONString stringByReplacingOccurrencesOfString:@"            \"header\":{"  withString:@"        \"header\":{"];
    }
    
    if ([requestJSONString containsString:@"            \"clientInfo\":{"]) {
        requestJSONString =  [requestJSONString stringByReplacingOccurrencesOfString:@"            \"clientInfo\":{"  withString:@"        \"clientInfo\":{"];
    }

    if ([requestJSONString containsString:@"             \"body\":{"]) {
        requestJSONString =  [requestJSONString stringByReplacingOccurrencesOfString:@"             \"body\":{"  withString:@"        \"body\":{"];
    }
    
        NSDebugLog(@"TCTNetworkEngine Tip:\nRequest  URL is:%@\nserviceName is: %@  \n%@",[self interfaceURL],[self serviceName] ,requestJSONString );
}

- (NSDictionary *)clientInfoDictionaryWithEncrypt:(TCTNetworkEncrypt *)encrypt
{

    NSString *s_TCTNetworkEngine_Version = encrypt.clientVersion ?: @"";
    NSString *s_TCTNetworkEngine_ADID = [TCTIdentifier getADId];
    
    NSString *s_TCTNetworkEngine_Audio_Refid = [TCTNetworkEngineConfig networkConfit_TCTNetworkEngine_Audio_Refid] ? : @"";
    NSString *s_TCTNetworkEngine_DevicePushToken = [TCTNetworkEngineConfig networkConfit_TCTNetworkEngine_DevicePushToken] ? : @"";
    NSString *s_TCTNetworkEngine_TagValue = [TCTNetworkEngineConfig networkConfit_TCTNetworkEngine_TagValue] ? : @"";
    
    NSMutableDictionary *clientInfoDictionary = [@{} mutableCopy];
    [clientInfoDictionary setValue:@"1" forKey:@"versionType"];

    [clientInfoDictionary setValue:@"11" forKey:@"platId"];
    
    [clientInfoDictionary setValue:s_TCTNetworkEngine_Version forKey:@"versionNumber"];
    [clientInfoDictionary setValue:s_TCTNetworkEngine_ADID forKey:@"macAddress"];
    
    struct utsname systemInfo; uname(&systemInfo);
    NSString *deviceMachine = [self predicateExtendString:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];
    NSString *bundleIdentifierKey = [self predicateExtendString:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey]];
    NSString *systemVersion = [self predicateExtendString:[[UIDevice currentDevice] systemVersion]];
    
    NSString *extend = [NSString stringWithFormat:@"2^%@,4^%@,5^%@", bundleIdentifierKey, systemVersion, deviceMachine];
    [clientInfoDictionary setValue:extend forKey:@"extend"];
    
    NSString *refId = s_TCTNetworkEngine_Audio_Refid;
    [clientInfoDictionary setValue:refId forKey:@"refId"];
    
    NSString *clientIp = [TCTIdentifier IP];
    [clientInfoDictionary setValue:clientIp forKey:@"clientIp"];
    
    NSString *deviceId = [TCTIdentifier deviceId];
    [clientInfoDictionary setValue:deviceId forKey:@"deviceId"];
    
    NSString *devicePushToken = s_TCTNetworkEngine_DevicePushToken;
    if ([devicePushToken length] > 0) {
        [clientInfoDictionary setValue:devicePushToken forKey:@"pushInfo"];
    }
    NSString *tag = s_TCTNetworkEngine_TagValue;
    if (tag.length > 0) {
        [clientInfoDictionary setValue:tag forKey:@"tag"];
    }
    
    /** 20150113 新增networkType字段，供中间层使用 */
    NSString *networkTypeString = [[TCTNetworkEngineConfig shareInstance].protocolEngine stringFromNetworkReachabilityStatus];
    [clientInfoDictionary setValue:networkTypeString forKey:@"networkType"];
    
    [clientInfoDictionary setValue:[TCTNetworkEngineConfig cbdSessionId] forKey:@"sessionId"];
    
    
    return clientInfoDictionary;
}

- (NSDictionary *)headDictionaryWithServiceName:(NSString *)serviceName withEncryptEffort:(NSString *)encryptEffort withEncrypt:(TCTNetworkEncrypt *)encrypt
{
    NSString *s_TCTNetworkEngine_ProtocolVer = encrypt.protocolVer ?: @"";
    NSString *s_TCTNetworkEngine_AccountID = encrypt.accountID ?: @"";
    
    NSMutableDictionary *header = [@{} mutableCopy];
    [header setValue:s_TCTNetworkEngine_ProtocolVer forKey:@"version"];
    [header setValue:s_TCTNetworkEngine_AccountID forKey:@"accountID"];
    [header setValue:serviceName forKey:@"serviceName"];
    
    NSString *reqTime = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
    [header setValue:reqTime forKey:@"reqTime"];
    
    NSString *digitalSign = [self digitalSignWithAccountId:s_TCTNetworkEngine_AccountID reqTime:reqTime serviceName:serviceName version:s_TCTNetworkEngine_ProtocolVer withEncrypt:encrypt];
    [header setValue:digitalSign forKey:@"digitalSign"];
    
    [header setValue:encryptEffort forKey:@"encryptEffort"];
    return header;
}

- (NSString *)digitalSignWithAccountId:(NSString *)accountID_
                               reqTime:(NSString *)reqTime_
                           serviceName:(NSString *)serviceName_
                               version:(NSString *)version_
                           withEncrypt:(TCTNetworkEncrypt *)encrypt
{
    NSString *accountID = [NSString stringWithFormat:@"AccountID=%@", [accountID_ lowercaseString]];
    NSString *reqTime = [NSString stringWithFormat:@"ReqTime=%@", reqTime_];
    NSString *serviceName = [NSString stringWithFormat:@"ServiceName=%@", serviceName_];
    NSString *version = [NSString stringWithFormat:@"Version=%@", version_];
    
    NSArray *keyArray = @[accountID, reqTime, serviceName, version];
    NSString *key = [[keyArray componentsJoinedByString:@"&"] stringByAppendingString:(encrypt.digitalSignPrivateKey ?: @"")];
    return [key tc_MD5EncodedString];
}

#pragma mark - 20150324 extend 过滤^ , [ ] { } " : 等特殊符号
- (NSString *)predicateExtendString:(NSString *)extendString {
    return [NSString tc_replaceOccurrencesOfString:[NSString tc_replaceOccurrencesOfString:extendString withString:@"_" options:NSLiteralSearch replaceArray:@[@",", @"，"]] withString:@"" options:NSLiteralSearch replaceArray:@[@"^", @"{", @"}", @"[", @"]", @"\"", @":"]];
}

@end
