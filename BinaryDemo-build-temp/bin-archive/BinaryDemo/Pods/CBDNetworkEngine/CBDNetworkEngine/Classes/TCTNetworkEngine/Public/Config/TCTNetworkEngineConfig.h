//
//  TCTNetworkEngineConfig.h
//  CarBaDa
//
//  Created by Jabir-Zhang on 2021/1/29.
//  Copyright © 2021 wyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCTNetworkEncrypt.h"
#import "TCTNetworkDebug.h"
#import "TCTProtocolEngine.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TCTNetworkingChangeToNoNetworkNotification; //有网 -> 无网 通知
extern NSString * const TCTNetworkingChangeToNetworkReachabilityNotification;//无网 -> 有网 通知

@interface TCTNetworkEngineConfig : NSObject
@property (nonatomic, strong) TCTProtocolEngine *protocolEngine;
@property (nonatomic, strong) TCTNetworkDebug *networkDebug;

+ (instancetype)shareInstance;

+ (NSString *)cbdSessionId;
+ (void)reloadCBDSessionId;
+ (void)setCBDSecurity:(NSString *)sSecurity;
+ (NSString *)cbdSecurity;
/// 清除网络缓存
+ (void)cbdClearResponseDataCache;

//老框架中保留
+ (NSString *)networkConfit_TCTNetworkEngine_DevicePushToken;   //pushToken，从-application:didRegisterForRemoteNotificationsWithDeviceToken获取，可为nil
+ (NSString *)networkConfit_TCTNetworkEngine_Audio_Refid;       //refid，可为nil
+ (NSString *)networkConfit_TCTNetworkEngine_KeyChain_Key;      //KeyChain的Key，从KeyChain获取deviceId，可为nil
+ (NSString *)networkConfit_TCTNetworkEngine_TagValue;          //页面跟踪TAG，可为nil

@end

NS_ASSUME_NONNULL_END
