//
//  TCTNetworkEngine.h
//  TCTNetworkEngine
//
//  Created by maxfong on 15-01-01.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//  Version 1.5.5 , updated_at 2015-06-03.

/** TCTNetworkEngine是同程旅游iOS同中间层通信的核心，基于iOS 6.0编译的静态库，任何使用问题，在论坛反馈：http://172.16.2.38/ios/?p=1161
 TCTRequestObject是请求(Request)实体基类，所有继承此类的类名必须以Request开头
 TCTResponseObject是响应(Response)实体基类，所有继承此类的类名必须以Response开头(兼容基类是NSObject)
 ProtocolEngine为请求引擎，不建议直接调用；
 
 TCTNetworkEngine引用Security.framework、MobileCoreServices.framework、SystemConfiguration.framework、CoreLocation.framework、CoreTelephony.framework、AdSupport.framework
 */

/** 因项目原因，使用本库必须外部实现TCTNetworkEngine配置类，实现动态调用的目的
 @interface TCTNetworkEngineFetchConfig : NSObject
 
 + (id)networkConfit_TCTNetworkEngine_engineObject;  //协议引擎，根据引擎实例才能获取request对象，默认为nil
 
 + (NSString *)networkConfit_TCTNetworkEngine_DevicePushToken;   //pushToken，从-application:didRegisterForRemoteNotificationsWithDeviceToken获取，可为nil
 + (NSString *)networkConfit_TCTNetworkEngine_Audio_Refid;       //语音的refid，可为nil
 + (NSString *)networkConfit_TCTNetworkEngine_KeyChain_Key;      //KeyChain的Key，从KeyChain获取deviceId，可为nil
 + (NSString *)networkConfit_TCTNetworkEngine_TagValue;          //页面跟踪TAG，可为nil
 
 @end
 */

#import "TCTProtocolEngine.h"
#import "TCTNetworkError.h"
#import "TCTNetworkEncrypt.h"
#import "TCTResponseObject.h"
#import "TCTRequestObject.h"

/** Entity Protocol */
#import "TCTRequestObjectDelegate.h"
#import "TCTObjectOperationDelegate.h"
#import "TCTNetworkEngineElementProtocol.h"

/** Engine 扩展 */
#import "TCTIdentifier.h"
#import "TCTNetworkDebug.h"

/** Foundation 扩展 */
#import "NSObject+PublicParse.h"
#import "NSString+PublicEncrypt.h"
#import "NSData+PublicEncrypt.h"
