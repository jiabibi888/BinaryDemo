//
//  TCTRequestObjectDelegate.h
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-8.
//
//

#import <Foundation/Foundation.h>

@class TCTNetworkError;

@protocol TCTRequestObjectDelegate <NSObject>

- (NSString *)interfaceURL; /** 中间层定义的链接地址 */
- (NSString *)serviceName;  /** 中间层定义的服务名 */

/** 客户端判断是否需要缓存
256  重定义 缓存使用
 */
- (BOOL)needCache;
@property (nonatomic, copy) NSString *cacheKey;

@optional

/** 特殊方法，可传自定义参数，供H5使用 */
- (NSDictionary *)ownParamsDictionary;

/** 请求类设置响应类名，兼容不同请求有响应实体的情况 */
- (NSString *)ownResponseClassName;

/** 请求设置加密方式，不执行统一管理 */
- (NSInteger)ownEncryptType;

@end
