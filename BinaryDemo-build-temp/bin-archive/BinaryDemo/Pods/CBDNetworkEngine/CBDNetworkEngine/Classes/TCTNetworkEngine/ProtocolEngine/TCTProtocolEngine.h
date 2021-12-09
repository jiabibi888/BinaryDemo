//
//  TCTProtocolEngine.h
//
//  Fix by maxfong on 14-10-08.
//  Copyright 2011 TongCheng. All rights reserved.
//

#import "TCTRequestObjectDelegate.h"

@class TCTNetworkEncrypt;

typedef NS_ENUM(NSInteger, TCTNetworkReachabilityStatus) {
    TCTNetworkReachabilityStatusUnknown          = -1,
    TCTNetworkReachabilityStatusNotReachable     = 0,
    TCTNetworkReachabilityStatusReachableViaWWAN = 1,
    TCTNetworkReachabilityStatusReachableViaWiFi = 2
};

/** 自定义设置，供operationOptions集合内数据使用 */
extern NSString * const TCTRequestJSONString;
extern NSString * const TCTRequestServiceName;
extern NSString * const TCTRequestEntityObject;
extern NSString * const TCTRequestIsCache;
extern NSString * const TCTResponseEntityName;
extern NSString * const TCTNetworkErrorEntity;
extern NSString * const TCTResponseDescription;

/** 自定义设置，供响应回调options使用 */
extern NSString * const TCTCallBackResponse;
extern NSString * const TCTCallBackResponseString;
extern NSString * const TCTCallBackResponseData;
extern NSString * const TCTCallBackRequest;

typedef void(^TCTRequestProgressBlock)(NSUInteger receivedSize, long long expectedSize);
typedef void(^TCTRequestSuccessBlock)(id responseObject, NSDictionary *options);
typedef void(^TCTRequestFailBlock)(TCTNetworkError *error, NSDictionary *options);

@interface TCTProtocolEngine : NSObject

/** 当前网络是否可用 */
@property (nonatomic, assign, readonly, getter = isReachable) BOOL reachable;
/** 当前网络状态 */
@property (nonatomic, assign, readonly) TCTNetworkReachabilityStatus networkReachabilityStatus;

/** 当前请求数 */
@property (nonatomic, assign, readonly) NSUInteger requestCount;
/** requestOperation集合 */
@property (nonatomic, strong, readonly) NSMutableDictionary *requestQueue;
/** 根据objectIdentifier保存的属性 */
@property (nonatomic, strong, readonly) NSMutableDictionary *operationOptions;
/** 加密对象 */
@property (nonatomic, strong) TCTNetworkEncrypt *encrypt;

//根据加密对象进行初始化
- (instancetype)initWithEncrypt:(TCTNetworkEncrypt *)encrypt;

/** 发送请求
 *
 *  @param request 请求实体，需要实现TCTRequestObjectDelegate且类名以Request开头
 *
 *  @return objectIdentifier
 */
- (NSString *)sendRequest:(id<TCTRequestObjectDelegate>)request;

/** 根据objectIdentifier取消对应请求
 *
 *  @param key sendRequest返回值
 *
 *  @return 操作结果
 */
- (BOOL)cancelRequestWithKey:(NSString *)key;
/** 批量取消请求队列 */
- (BOOL)cancelRequestWithKeys:(NSArray *)keys;
/** 取消当前所有请求 */
- (void)cancelAllRequest;

/** 根据objectIdentifier获取request实体对象
 *
 *  @param key objectIdentifier
 *
 *  @return 符合TCTRequestObjectDelegate的reqeust实体对象
 */
- (id<TCTRequestObjectDelegate>)requestObjectWithKey:(NSString *)key;

@end

@interface TCTProtocolEngine (NetworkReachabilityStatus)

/** 开始监听网络状态, 默认开启*/
- (void)startMonitoring;

/** 停止监听网络状态, 关闭监听后接口将接收不到networkType */
- (void)stopMonitoring;

/**
 *  返回当前网络状态
 *
 *  @return 包含：unreachable、wifi、2G、3G、4G、wwan、unknown
 */
- (NSString *)stringFromNetworkReachabilityStatus;

@end

extern NSString * const TCTNetworkEngineRequestWillSendNotification;
extern NSString * const TCTNetworkEngineRequestDidSendNotification;

extern NSString * const TCTNetworkEngineResponseWillHandleNotification;
extern NSString * const TCTNetworkEngineResponseWillCallbackNotification;
extern NSString * const TCTNetworkEngineResponseDidHandleNotification;

extern NSString * const TCTNetworkEngineDebugMonitorInterfaceNotification;  /** Debug模式监听 */
extern NSString * const TCTNetworkEngineValidRequestErrorNotification;      /** 验证请求错误 */
extern NSString * const TCTNetworkEngineValidResponseErrorNotification;     /** 验证响应错误 */
extern NSString * const TCTNetworkingReachabilityDidChangeNotification;     /** 网络变更监听 */
extern NSString * const TCTNetworkingInterfaceServiceErrorNotification;     /** 接口错误监听 */
/** 有网 -> 无网 通知 */
extern NSString * const TCTNetworkingChangeToNoNetworkNotification;
/** 无网 -> 有网 通知 */
extern NSString * const TCTNetworkingChangeToNetworkReachabilityNotification;

extern NSString * const TCTNetworkingReceivedServiceTimeNotification;//收到服务器时间
/** 接口错误数据KEY */
extern NSString * const TCTInterfaceServiceErrorResponseStatusCode;
extern NSString * const TCTInterfaceServiceErrorCode;
extern NSString * const TCTInterfaceServiceErrorUserInfo;

typedef void(^TCTNetworkEngineBuildBlock)(TCTNetworkEncrypt *encrypt);

@interface TCTProtocolEngine (Extend)

/**
 *  创建ProtocolEngine, 参数参考@class TCTNetworkEncrypt
 */
+ (instancetype)startWithBuilder:(TCTNetworkEngineBuildBlock)block;

@end
