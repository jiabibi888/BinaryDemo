//
//  TCTHTTPRequestOperationManager.h
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-8.
//
//

#import <AFNetworking/AFHTTPSessionManager.h>

@class TCTNetworkEncrypt;

@interface TCTHTTPRequestOperationManager : AFHTTPSessionManager

- (nullable NSURLSessionDataTask *)POST:(nullable NSString *)URLString
                             parameters:(nullable id)parameters
                                success:(nullable void (^)(NSURLSessionDataTask *_Nullable task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError* _Nullable error))failure
                                encrypt:(nullable TCTNetworkEncrypt *)encrypt
                          cacheResponse:(BOOL)cacheResponse
                               cacheKey:(nullable NSString *)cacheKey
                            serviceName:(nullable NSString*)sName;

- (void)archiveResponseData:(id _Nullable )responseData withKey:( nullable NSString *)key;
- (void)manageCacheArrayAddWithKey:(NSString *_Nullable)key;
- (void)clearResponseDataCache;
@end
