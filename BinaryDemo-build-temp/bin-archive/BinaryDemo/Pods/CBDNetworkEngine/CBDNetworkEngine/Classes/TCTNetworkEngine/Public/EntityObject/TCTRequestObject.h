//
//  TCTRequestObject.h
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-8.
//
//

#import "TCTProtocolEngine.h"
#import "TCTObjectOperationDelegate.h"

@interface TCTRequestObject : NSObject <TCTRequestObjectDelegate, TCTObjectOperationDelegate>

/** 默认实现TCTRequestObjectDelegate协议 */
/** 中间层定义的链接地址
 */
@property (nonatomic, retain) NSString *interfaceURL;
/** 中间层定义的服务名 */
@property (nonatomic, retain) NSString *serviceName;
/** 客户端判断是否需要缓存
256  重定义 缓存使用
 */
@property (nonatomic, assign) BOOL needCache;


/** 客户端判断是否需要失败重连
 *  重连次数统一设置：默认TCTRequestReconnectionTmies，暂无单独设置
 */
@property (nonatomic, assign) BOOL needReconnection;

/** 请求成功回调，可不设置，默认nil */
@property (nonatomic, copy) TCTRequestSuccessBlock successBlock;
/** 请求失败回调，可不设置，默认nil */
@property (nonatomic, copy) TCTRequestFailBlock failBlock;

/** 请求进度回调，可不设置，默认nil */
@property (nonatomic, copy) TCTRequestProgressBlock progressBlock;
/** 是否进行中 */
@property (nonatomic, assign, readonly, getter = isExecuting) BOOL executing;

/** 是否已取消 */
@property (nonatomic, assign, readonly, getter = isCancelled) BOOL cancelled;
/** 该请求已经重连过的次数 */
@property (nonatomic, assign) NSUInteger reconnectedTimes;


/** 取消当前请求 */
- (void)cancel;


/** 对已保存的请求实体直接发起请求*/
- (void)start;
/**
 *  对successBlock和failBlock赋值并执行start
 *
 *  @param success 同successBlock
 *  @param fail    同failBlock
 */
- (void)startWithSuccessBlock:(TCTRequestSuccessBlock)success
                    failBlock:(TCTRequestFailBlock)fail;

- (void)startAndCacheWithSuccessBlock:(TCTRequestSuccessBlock)success failBlock:(TCTRequestFailBlock)fail  cacheKey:(NSString *)key;

/** 对successBlock和failBlock进行nil赋值，设置executing为nil */
- (void)clearCompletionBlock;

/** 根据objectIdentifier可获取请求TCTRequestEntityObject，不建议使用 */
@property (nonatomic, strong, readonly) NSString *objectIdentifier;

@end

@interface TCTRequestObject (PublicEncrypt)

/** 获取request的JSONString，默认TCTNetworkEncrypt_Req加密类型 */
- (NSString *)requestJSONString;

@end
