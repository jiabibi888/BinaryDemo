 //
//  TCTProtocolEngine.m
//
//  Fix by maxfong on 14-10-08.
//  Copyright 2011 TongCheng. All rights reserved.
//

#import "TCTProtocolEngine.h"
#import "TCTNetworkError.h"
#import "AFNetworking.h"
#import "TCTRequestObject+Encrypt.h"
#import "TCTHTTPRequestOperationManager.h"
#import "NSObject+NetworkEngineParse.h"
#import "TCTNetworkEncrypt+Handle.h"
#import "NSString+NetworkEngineEncrypt.h"
#import <objc/runtime.h>
#import "TCTNetworkEngineConfig.h"
#import "TCFoundation.h"

static NSString * const kRequestClassPrefix = @"Request";
static NSString * const kResponseClassPrefix = @"Response";

#pragma mark -
NSString * const TCTRequestJSONString       = @"TCTRequestJSONString";
NSString * const TCTRequestServiceName      = @"TCTRequestServiceName";
NSString * const TCTRequestEntityObject     = @"TCTRequestEntityObject";
NSString * const TCTRequestIsCache          = @"TCTRequestIsCache";
NSString * const TCTResponseEntityName      = @"TCTResponseEntityName";
NSString * const TCTResponseDescription      = @"TCTResponseDescription";
NSString * const TCTNetworkErrorEntity        = @"TCTNetworkErrorEntity";

NSString * const TCTCallBackResponse        = @"TCTCallBackResponse";
NSString * const TCTCallBackResponseString  = @"TCTCallBackResponseString";
NSString * const TCTCallBackResponseData    = @"TCTCallBackResponseData";
NSString * const TCTCallBackRequest         = @"TCTCallBackRequest";

NSString * const TCTInterfaceServiceErrorResponseStatusCode = @"TCTInterfaceServiceErrorResponseStatusCode";
NSString * const TCTInterfaceServiceErrorCode = @"TCTInterfaceServiceErrorCode";
NSString * const TCTInterfaceServiceErrorUserInfo = @"TCTInterfaceServiceErrorUserInfo";

NSString * const TCTNetworkEngineRequestWillSendNotification = @"TCTNetworkEngineRequestWillSendNotification";
NSString * const TCTNetworkEngineRequestDidSendNotification = @"TCTNetworkEngineRequestDidSendNotification";

NSString * const TCTNetworkEngineResponseWillHandleNotification = @"TCTNetworkEngineResponseWillHandleNotification";
NSString * const TCTNetworkEngineResponseWillCallbackNotification = @"TCTNetworkEngineResponseWillCallbackNotification";
NSString * const TCTNetworkEngineResponseDidHandleNotification = @"TCTNetworkEngineResponseDidHandleNotification";

NSString * const TCTNetworkEngineDebugMonitorInterfaceNotification = @"TCTNetworkEngineDebugMonitorInterfaceNotification";
NSString * const TCTNetworkEngineValidRequestErrorNotification = @"TCTNetworkEngineValidRequestErrorNotification";
NSString * const TCTNetworkEngineValidResponseErrorNotification = @"TCTNetworkEngineValidResponseErrorNotification";
NSString * const TCTNetworkingReachabilityDidChangeNotification = @"TCTNetworkingReachabilityDidChangeNotification";
NSString * const TCTNetworkingInterfaceServiceErrorNotification = @"TCTNetworkingInterfaceServiceErrorNotification";

NSString * const TCTNetworkingChangeToNoNetworkNotification = @"TCTNetworkingChangeToNoNetworkNotification";
NSString * const TCTNetworkingChangeToNetworkReachabilityNotification = @"TCTNetworkingChangeToNetworkReachabilityNotification";
NSString * const TCTNetworkingReceivedServiceTimeNotification = @"TCTNetworkingReceivedServiceTimeNotification";


static NSUInteger TCTRequestRetryTimes = 3;     //失败重连次数

@interface TCTProtocolEngine()

@property (nonatomic, assign, readwrite) TCTNetworkReachabilityStatus networkReachabilityStatus;
@property (nonatomic, strong, readwrite) NSMutableDictionary *requestQueue;
@property (nonatomic, strong, readwrite) NSMutableDictionary *operationOptions;
@property (nonatomic, strong) TCTHTTPRequestOperationManager *operationManager;

@property (nonatomic, strong) NSMutableDictionary *debugRequestParsing;//存每个请求是否需要debug Mock数据解析

@end

#pragma mark -
@implementation TCTProtocolEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestQueue = [[NSMutableDictionary alloc] init];
        self.debugRequestParsing = [[NSMutableDictionary alloc] init];
        self.encrypt = TCTNetworkEncrypt.new;
        [self startMonitoring];
    }
    return self;
}

- (instancetype)initWithEncrypt:(TCTNetworkEncrypt *)encrypt {
    TCTProtocolEngine *engine = [self init];
    engine.encrypt = encrypt;
    return engine;
}

- (NSUInteger)requestCount {
    return self.requestQueue.count;
}

#pragma mark - sendRequest
- (NSString *)sendRequest:(id<TCTRequestObjectDelegate>)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineRequestWillSendNotification object:request];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *requestJSONString = @"";
    if ([request respondsToSelector:@selector(requestJSONStringWithEncrypt:)]) {
        if ([request isKindOfClass:[TCTRequestObject class]]) {
            requestJSONString = [((TCTRequestObject *)request) requestJSONStringWithEncrypt:self.encrypt];
        }
    }
    
    if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
        
        NSAssert([request interfaceURL] != nil, @"TCTNetworkEngine Tip:request对象interfaceURL未设置");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineDebugMonitorInterfaceNotification object:@[request, @{@"requestAddr":[request interfaceURL], @"serviceName": [request serviceName], @"requestParam":(requestJSONString)}]];
    }

    NSString *objectIdentifier = nil;
    if ([request respondsToSelector:@selector(objectIdentifier)]) {
        objectIdentifier = [request performSelector:@selector(objectIdentifier)];
    }
    if (self.operationOptions[objectIdentifier]) return objectIdentifier;   //屏蔽同时发出多条请求

    NSString *responseClassName = [self responseClassNameWithRequest:request];
    NSDictionary *options = @{TCTResponseEntityName: responseClassName,
                              TCTRequestEntityObject:request,
                              TCTRequestIsCache: @([request needCache]),
                              TCTRequestServiceName: [request serviceName],
                              TCTRequestJSONString:requestJSONString};
    
    if (!self.operationOptions) {
        self.operationOptions = [[NSMutableDictionary alloc] init];
    }
    
    self.operationOptions[objectIdentifier] = options;
    
    if (!self.operationManager) {
        self.operationManager = [TCTHTTPRequestOperationManager manager];//单例
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            self.operationManager.operationQueue.maxConcurrentOperationCount = 16;
        }
    }
    //数据测试
#ifdef DEBUGMODEL
    BOOL bDataTest =  [[NSUserDefaults standardUserDefaults] boolForKey:@"CarBaDa_DataTest"];
    if (bDataTest) {
        [self sendRequst:request requestJSONString:requestJSONString objectIdentifier:objectIdentifier isDebugRequest:YES];
    } else {
        [self sendRequst:request requestJSONString:requestJSONString objectIdentifier:objectIdentifier isDebugRequest:NO];
    }
#else
    [self sendRequst:request requestJSONString:requestJSONString objectIdentifier:objectIdentifier isDebugRequest:NO];
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineRequestDidSendNotification object:request];
    
    return objectIdentifier;
}

- (void)sendRequst:(id<TCTRequestObjectDelegate>)request requestJSONString:(NSString *)requestJSONString objectIdentifier:(NSString *)objectIdentifier isDebugRequest:(BOOL)bDebugRequest{
    NSNumber *nDebugRequest = [NSNumber numberWithBool:bDebugRequest];
    [self.debugRequestParsing setValue:nDebugRequest forKey:objectIdentifier];
    __weak __typeof(self) weakSelf = self;
    if (bDebugRequest) {
        //数据测试
        NSMutableDictionary *bodyDictionary = [[NSMutableDictionary alloc] init];
        NSString *sInterfaceUrl = [request interfaceURL];
        NSURL *interfaceUrl = [NSURL URLWithString:sInterfaceUrl];
        NSString *sHost = [NSString stringWithFormat:@"%@://%@", interfaceUrl.scheme, interfaceUrl.host];
        NSString *sPath = [sInterfaceUrl stringByReplacingOccurrencesOfString:sHost withString:@""];
        [bodyDictionary setValue:sPath forKey:@"path"];
        [bodyDictionary setValue:[request serviceName] forKey:@"servicename"];
        [bodyDictionary setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"CarBaDa_DataTestBugID"] forKey:@"bugid"];
        [bodyDictionary setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"CarBaDa_DataTestUserName"] forKey:@"username"];
        [bodyDictionary setValue:@"1" forKey:@"reqbodyencrypt"];
        [bodyDictionary setValue:requestJSONString forKey:@"reqbody"];
        NSString *tempRequestJSONString = nil;
        NSError *error = nil;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:bodyDictionary
                                                           options:0
                                                             error:&error];
        if (JSONData) {
            tempRequestJSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        }
        NSURLSessionDataTask * task=[self.operationManager POST:@"http://blackstone.qa.chebada.com/apis/exapis/mock"
                                                     parameters:tempRequestJSONString
                                                        success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
                                                            
                                                            if (responseObject) {
                                                                if ([responseObject isKindOfClass:[NSNull class]]) {
                                                                    [weakSelf requestFinishedWithOperation:task data:nil requestKey:objectIdentifier failError:nil];
                                                                } else {
                                                                    [weakSelf requestFinishedWithOperation:task data:responseObject requestKey:objectIdentifier failError:nil];
                                                                }
                                                            } else {
                                                                [weakSelf requestFinishedWithOperation:task data:nil requestKey:objectIdentifier failError:nil];
                                                            }
                                                            
                                                            
                                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                                                            
                                                            NSDebugLog(@"%@'",error);
                                                            
                                                            [weakSelf requestFinishedWithOperation:task data:nil requestKey:objectIdentifier failError:error];
                                                        } encrypt:self.encrypt
                                                  cacheResponse:[request needCache]
                                                       cacheKey:request.cacheKey
                                                    serviceName:[request serviceName]];
        [self.requestQueue setValue:task forKey:objectIdentifier];
    } else {
        NSURLSessionDataTask * task=[self.operationManager POST:[request interfaceURL]
                                                     parameters:requestJSONString
                                                        success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
                                                            
                                                            if (responseObject) {
                                                                if ([responseObject isKindOfClass:[NSNull class]]) {
                                                                    [weakSelf requestFinishedWithOperation:task data:nil requestKey:objectIdentifier failError:nil];
                                                                } else {
                                                                    [weakSelf requestFinishedWithOperation:task data:responseObject requestKey:objectIdentifier failError:nil];
                                                                }
                                                            } else {
                                                                [weakSelf requestFinishedWithOperation:task data:nil requestKey:objectIdentifier failError:nil];
                                                            }
                                                            
                                                            
                                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                                                            
                                                            NSDebugLog(@"%@'",error);
                                                            
                                                            [weakSelf requestFinishedWithOperation:task data:nil requestKey:objectIdentifier failError:error];
                                                        } encrypt:self.encrypt
                                                  cacheResponse:[request needCache]
                                                       cacheKey:request.cacheKey
                                                    serviceName:[request serviceName]];
        [self.requestQueue setValue:task forKey:objectIdentifier];
    }
}

#pragma mark -     -----------------------------------------------  请求完成处理      -----------------------------------------------
- (void)requestFinishedWithOperation:(NSURLSessionDataTask *)operation data:(NSData*)data requestKey:(id)objectIdentifier failError:(NSError * _Nullable)error
{
    NSDictionary *options = self.operationOptions[objectIdentifier];

    [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineResponseWillHandleNotification object:options];
    
    if (!options && [[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
        NSDebugLog(@"TCTNetworkEngine Tip:请求已被取消");   //请求缓存机制可以更优化，数组保存对象控制
        return;
    }

     id requestEntityObject = options[TCTRequestEntityObject];

    NSMutableDictionary *callBackOptions = [@{} mutableCopy];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)operation.response;
    [callBackOptions setValue:httpResponse?: @"" forKey:TCTCallBackResponse];
    NSError* erro;
    NSString* responseString =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if (erro) {
      NSDebugLog(@"%@",erro);
    }
    
    [callBackOptions setValue:responseString ?: @"" forKey:TCTCallBackResponseString];
    [callBackOptions setValue:data ? : @"" forKey:TCTCallBackResponseData];
    [callBackOptions setValue:operation.response.URL ?: @"" forKey:TCTCallBackRequest];
    
    //非缓存处理流程
    if (httpResponse.statusCode == 200){
        //数据测试增加先判断是否获取到测试数据，合法则使用测试数据 byJabir 2019.5.6
        if ([self checkCBDDebugDealResponseStatus_SuccessWithOperation:operation data:data options:options requestKey:objectIdentifier]) {
            [self.debugRequestParsing removeObjectForKey:objectIdentifier];
            [self CBDDealResponseStatus_SuccessWithOperation:operation data:data options:options callBackOptions:callBackOptions requestEntityObject:requestEntityObject];
        } else {
            //不合法则重新走正常接口请求
            NSString *sRequestJSONString = options[TCTRequestJSONString];
            [self.debugRequestParsing setValue:[NSNumber numberWithBool:NO] forKey:objectIdentifier];
            [self requestReconnectWithObjectIdentifier:objectIdentifier requestEntity:requestEntityObject requestJSONString:sRequestJSONString];
        }
    }
    
    //失败  有缓存的情况  响应数据处理  ---  缓存不验证
    else if (!operation && [self isNeedResponseDataCacheRequest:requestEntityObject] ) {
        [self CBDDealResponseStatus_CacheWithOperation:operation data:data options:options callBackOptions:callBackOptions  requestEntityObject:requestEntityObject];
        
    }
    //失败
    else {
        [self CBDDealResponseStatus_FailWithOperation:operation data:data options:options callBackOptions:callBackOptions requestEntityObject:requestEntityObject requestKey:objectIdentifier failError:error];
     
    }
   
    //Vic:SaveClientLog
    [self CBDDealResponseStatus_SaveClientLogWithOperation:operation options:options];
    
    [self removeRequestQueueWithKey:objectIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineResponseDidHandleNotification object:options];
}


#pragma mark - 校验——数据mock功能下校验数据是否合法
- (BOOL)checkCBDDebugDealResponseStatus_SuccessWithOperation:(NSURLSessionDataTask *)operation data:(NSData*)data options:(NSDictionary *)options requestKey:(id)objectIdentifier{
    NSNumber *nDebugRequestParsing =[self.debugRequestParsing valueForKey:objectIdentifier];
    if (!nDebugRequestParsing.boolValue) {
        return YES;//如果不需要解析，则直接返回YES
    }
    NSString *tempresponseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *responseString = nil;
    
    TCTNetworkEncryptType encryptType = self.encrypt.type;
//    //20190709 Jabir修改，判断是否单独设置了加密类型
//    TCTRequestObject *request = options[TCTRequestEntityObject];
//    if ([request respondsToSelector:@selector(ownEncryptType)]) {
//        encryptType = [request ownEncryptType];
//    }
//
    //根据加密类型强制判断，防止响应被篡改
    switch (encryptType) {
        case TCTNetworkEncrypt_None:
        {
            responseString = tempresponseString;   //response不加密
        }
            break;
        case TCTNetworkEncrypt_Req:
        {
            responseString = tempresponseString;   //response不加密
        }
            break;
        case TCTNetworkEncrypt_AES:
        {
            responseString = [NSString tc_aesDecryptAndBase64DecodeByCBD:tempresponseString withKey:self.encrypt.rspBodyAESKey];
        }
            break;
        case TCTNetworkEncrypt_AES_UnBody:
        {
            responseString = tempresponseString;   //response不加密
        }
            break;
        default: break;
    }
    
    if ([[TCTNetworkEngineConfig shareInstance].networkDebug isLogResponse]) {
        
        [self logResponseJson:operation responseString:responseString options:options];
        
        if ([responseString length] <= 0) {
            //当前是否因为无网络没有返回数据
            if ([self isReachable]) {
                NSDebugLog(@"TCTNetworkEngine Tip:黑石mock接口未返回正确数据");
            }
            else {
                NSDebugLog(@"TCTNetworkEngine Tip:当前网络无法请求数据");
            }
        }
    }
    
    if (responseString.length > 0) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;
        NSDictionary *allHeaderFields = response.allHeaderFields;
        if([allHeaderFields.allKeys containsObject:@"bscode"]){
            NSString *bscode = allHeaderFields[@"bscode"];
            if ([bscode integerValue] == 0) {
                return YES;
            }
        } else {
            return NO;
        }

    }
    return NO;
}

#pragma mark - statusCode == 200
- (void)CBDDealResponseStatus_SuccessWithOperation:(NSURLSessionDataTask *)operation data:(NSData*)data options:(NSDictionary *)options callBackOptions:(NSMutableDictionary *)callBackOptions requestEntityObject:(id)requestEntityObject{
    id responseObject = [self responseObjectWithOperation:operation data:data options:options];

    [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineResponseWillCallbackNotification object:options];
    
    if (responseObject) {
        if ([responseObject isKindOfClass:[TCTNetworkError class]]) {
            //把请求也传入callbackoption里，用于自动登录失效记录
            [callBackOptions setValue:[options valueForKey:TCTRequestJSONString] forKey:TCTRequestJSONString];
            
            TCTNetworkError *error = responseObject;
            if (error.code == TCTErrorNetworkResponseValidFail) {
                [callBackOptions removeAllObjects];
            }
            
            if ([requestEntityObject respondsToSelector:@selector(failBlock)]) {
                TCTRequestFailBlock failBlock = [requestEntityObject performSelector:@selector(failBlock)];
                if (failBlock) dispatch_async(dispatch_get_main_queue(), ^{ failBlock(responseObject, callBackOptions); });
            }
        }
        else {
            //判断是否缓存请求
            if ([self isNeedResponseDataCacheRequest:requestEntityObject]) {
                [self CBDDealResponseStatus_updateCacheWithRequest:requestEntityObject data:data];
            }
            
            if ([requestEntityObject respondsToSelector:@selector(successBlock)]) {
                TCTRequestSuccessBlock successBlock = [requestEntityObject performSelector:@selector(successBlock)];
                NSString *des =  [self getSuccessDescription:data operation:operation options:options];
                if(des.length > 0)[callBackOptions setValue:des forKey:TCTResponseDescription];
                if (successBlock) dispatch_async(dispatch_get_main_queue(), ^{ successBlock(responseObject, callBackOptions); });
            }
        }
        
        if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineDebugMonitorInterfaceNotification object:@[responseObject]];
        }
        
    }else {
        
        if ([requestEntityObject respondsToSelector:@selector(successBlock)]) {
            TCTRequestSuccessBlock successBlock = [requestEntityObject performSelector:@selector(successBlock)];
            NSString *des =  [self getSuccessDescription:data operation:operation options:options];
            if(des.length > 0)[callBackOptions setValue:des forKey:TCTResponseDescription];
            
            if (successBlock) dispatch_async(dispatch_get_main_queue(), ^{ successBlock(nil, callBackOptions); });
        }
        
        if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
            BOOL isValid = [NSJSONSerialization isValidJSONObject:responseObject];
            if (isValid) {
                NSDebugLog(@"TCTNetworkEngine Tip:响应%@类名未按开发规范定义", options[TCTResponseEntityName]);
            }
            else {
                NSDebugLog(@"TCTNetworkEngine Tip:检查%@接口响应是否标准JSON", options[TCTRequestServiceName]);
            }
        }
    }
}

#pragma mark - 更新缓存
- (void)CBDDealResponseStatus_updateCacheWithRequest:(id<TCTRequestObjectDelegate>)request data:(NSData*)data{
    //缓存数据  写入/  更新      数据为未解密data
    //分页处理逻辑处理
    unsigned int count;
    BOOL isContainPageIndex = NO;
    objc_property_t *properties = class_copyPropertyList([request class],&count);// 获取对象里的属性列表
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        //PageIndex
        //pageIndex
        //pageindex
        //                        NSDebugLog(@"%@\n", propertyName);
        
        NSString *propertyNameLower = [propertyName lowercaseString]; //小写
        if ([propertyNameLower isEqualToString:@"pageindex"]) {

            NSString *thePageIndex =  [(TCTRequestObject *)request valueForKey:propertyName];
            
            if ([thePageIndex integerValue] == 1) {
                [self.operationManager archiveResponseData:data withKey:request.cacheKey];
            }
            
            isContainPageIndex = YES;
            break;
        }
        
    }
    free(properties);
    
    if (!isContainPageIndex) {
        [self.operationManager archiveResponseData:data withKey:request.cacheKey];
    }
}

#pragma mark - 获取缓存 并实现 successBlock
- (void)CBDDealResponseStatus_CacheWithOperation:(NSURLSessionDataTask *)operation data:(NSData*)data options:(NSDictionary *)options callBackOptions:(NSMutableDictionary *)callBackOptions requestEntityObject:(id)requestEntityObject{
        id responseObject = [self responseObjectWithOperation:operation data:data options:options];
        [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineResponseWillCallbackNotification object:options];
    
        if (responseObject) {
            
            if ([requestEntityObject respondsToSelector:@selector(successBlock)]) {
                TCTRequestSuccessBlock successBlock = [requestEntityObject performSelector:@selector(successBlock)];
                NSString *des =  [self getSuccessDescription:data operation:operation options:options];
                if(des.length > 0)[callBackOptions setValue:des forKey:TCTResponseDescription];
                if (successBlock) dispatch_async(dispatch_get_main_queue(), ^{ successBlock(responseObject, callBackOptions); });
            }
            
        }
}


#pragma mark - 失败的处理
- (void)CBDDealResponseStatus_FailWithOperation:(NSURLSessionDataTask *)operation data:(NSData*)data options:(NSDictionary *)options callBackOptions:(NSMutableDictionary *)callBackOptions requestEntityObject:(id)requestEntityObject  requestKey:(id)objectIdentifier failError:(NSError * _Nullable)error{
   
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)operation.response;
    
    NSString *requestJSONString = @"";
    
    if ([requestEntityObject respondsToSelector:@selector(requestJSONStringWithEncrypt:)]) {
        if ([requestEntityObject isKindOfClass:[TCTRequestObject class]]) {
            requestJSONString = [((TCTRequestObject *)requestEntityObject) requestJSONStringWithEncrypt:self.encrypt];
            //NSDebugLog(@"URL %@",[request interfaceURL]);
        } else { }
    }
   
    TCTErrorNetworkCallback status = TCTErrorNetworkCallbackUnKnown;
    
    NSString *errorDescription = nil;
    if ([self isReachable]) {
        //<<<<<<<<<<Debug Start
        if (!options && [[TCTNetworkEngineConfig shareInstance].networkDebug isDebug])
        {
            errorDescription = operation.error.localizedDescription;
        }
        //>>>>>>>>>>Debug End
        else {
            if (httpResponse.statusCode == 404) {
                errorDescription = @"服务器偷懒了，先去其他页面逛逛吧";
                status = TCTErrorNetworkCallbackFailWithServer;
            }
            else {
                errorDescription = @"网络不给力，再试试";
                status = TCTErrorNetworkCallbackUnReachable;
            }
        }
    }
    else {
        errorDescription = @"网络连接失败，请检查一下网络设置";
        status = TCTErrorNetworkCallbackUnReachable;
    }
    
    //请求失败回调
    [self requestFailCallBackStatus:status requestKey:objectIdentifier requestJSONString:requestJSONString httpResponse:httpResponse options:options requestEntityObject:requestEntityObject callBackOptions:callBackOptions errorDescription:errorDescription failError:error];
}



#pragma mark - equestFailCallBack
- (void)requestFailCallBackStatus:(TCTErrorNetworkCallback)status requestKey:(id)objectIdentifier requestJSONString:(NSString *)requestJSONString httpResponse:(NSHTTPURLResponse *)httpResponse options:(NSDictionary *)options  requestEntityObject:(id)requestEntityObject callBackOptions:(NSMutableDictionary *)callBackOptions errorDescription:(NSString *)errorDescription failError:(NSError * _Nullable)failError{
    
    //回调失败block
    TCTNetworkError *error = [TCTNetworkError errorWithDomain:@"requestFinishedWithOperation" code:status userInfo:@{TCTNetworkErrorDescription : errorDescription}];
    error.rspCode = httpResponse.statusCode;
    error.entityName = options[TCTResponseEntityName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineResponseWillCallbackNotification object:options];
    //2018.2.1 Jabir添加请求错误通知
    [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineValidResponseErrorNotification object:@{TCTNetworkErrorEntity:error}];
    
    if ([requestEntityObject respondsToSelector:@selector(failBlock)]) {
        TCTRequestFailBlock failBlock = [requestEntityObject performSelector:@selector(failBlock)];
        if (failBlock) dispatch_async(dispatch_get_main_queue(), ^{ failBlock(error, callBackOptions); });
    }
    //超时
    BOOL bServerError = (httpResponse.statusCode % 100 == 5) ? YES : NO;
    if (failError.code == -1001 || bServerError) {//请求超时或HTTP 5xx 服务器错误

//        if (requestEntityObject.needReconnection && requestEntityObject.reconnectedTimes < TCTRequestRetryTimes) {//请求允许重连且未超过重连次数
//            requestEntityObject.reconnectedTimes++;
//            //失败重连
//             NSDebugLog(@"%@   第%zd次重连",[requestEntityObject serviceName], requestEntityObject.reconnectedTimes);
//            [self requestReconnectWithObjectIdentifier:objectIdentifier requestEntity:requestEntityObject request:request requestJSONString:requestJSONString];
//        }
    }

    if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineDebugMonitorInterfaceNotification object:@[error]];
    }

}

#pragma mark - 重连请求
- (void)requestReconnectWithObjectIdentifier:(NSString *)objectIdentifier requestEntity:(TCTRequestObject *)requestEntityObject requestJSONString:(NSString *)requestJSONString{
    
    [self.operationManager POST:[requestEntityObject interfaceURL] parameters:requestJSONString success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        if (responseObject) {
            if ([responseObject isKindOfClass:[NSNull class]]) {
                [self requestFinishedWithOperation:task data:nil requestKey:objectIdentifier failError:nil];
            } else {
                NSString *responseClassName = [self responseClassNameWithRequest:requestEntityObject];
                NSDictionary *options = @{TCTResponseEntityName: responseClassName,
                                          TCTRequestEntityObject:requestEntityObject,
                                          TCTRequestIsCache: @([requestEntityObject needCache]),
                                          TCTRequestServiceName: [requestEntityObject serviceName],
                                          TCTRequestJSONString:requestJSONString};
                if (!self.operationOptions) {
                    self.operationOptions = [[NSMutableDictionary alloc] init];
                }
                self.operationOptions[objectIdentifier] = options;
                [self requestFinishedWithOperation:task data:responseObject requestKey:objectIdentifier failError:nil];
            }
        } else {
            
            [self requestFinishedWithOperation:task data:nil requestKey:objectIdentifier failError:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        if (requestEntityObject.reconnectedTimes < TCTRequestRetryTimes) {
            requestEntityObject.reconnectedTimes++;
            NSDebugLog(@"%@   第%zd次重连",[requestEntityObject serviceName], requestEntityObject.reconnectedTimes);
            [self requestReconnectWithObjectIdentifier:objectIdentifier requestEntity:requestEntityObject requestJSONString:requestJSONString];
        }
    } encrypt:self.encrypt cacheResponse:[requestEntityObject needCache] cacheKey:objectIdentifier serviceName:[requestEntityObject serviceName]];
}

#pragma mark - SaveClientLog
- (void)CBDDealResponseStatus_SaveClientLogWithOperation:(NSURLSessionDataTask *)operation options:(NSDictionary *)options{
    if ([[TCTNetworkEngineConfig shareInstance].networkDebug isSaveClientLog]) {
        NSMutableDictionary *dictionary = [@{} mutableCopy];
        if (options) [dictionary addEntriesFromDictionary:options];
        if (operation) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)operation.response;
            [dictionary setValue:@(httpResponse.statusCode) forKey:TCTInterfaceServiceErrorResponseStatusCode];
            [dictionary setValue:@(operation.error.code) forKey:TCTInterfaceServiceErrorCode];
            if (operation.error.userInfo) {
                [dictionary setValue:operation.error.userInfo forKey:TCTInterfaceServiceErrorUserInfo];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkingInterfaceServiceErrorNotification object:dictionary];
    }
}

#pragma mark - 是否需要/存在缓存
- (BOOL)isNeedResponseDataCacheRequest:(id<TCTRequestObjectDelegate>)request {
    if(([request needCache] && request.cacheKey.length > 0)  )//  需求变成 只要是失败就取缓存
    {
        return YES;
    }
    return NO;
}

#pragma mark -  响应数据  解析 验证   转对象
- (id)responseObjectWithOperation:(NSURLSessionDataTask *)operation data:(NSData*)data options:(NSDictionary *)options
{
    NSString *tempresponseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *responseString = nil;
    //20151124 by Jabir
    //自定义加密类型-隐藏功能
    TCTNetworkEncryptType encryptType = self.encrypt.type;
    
    //20150215 response验证
    //20190709 Jabir再修改，从下方挪到此处，从一开始解密就需要知道是否单独设置了加密类型
    TCTRequestObject *request = options[TCTRequestEntityObject];
    if ([request respondsToSelector:@selector(ownEncryptType)]) {
        encryptType = [request ownEncryptType];
    }
    
    //根据加密类型强制判断，防止响应被篡改
    switch (encryptType) {
        case TCTNetworkEncrypt_None:
        {
            responseString = tempresponseString;
        }
            break;
        case TCTNetworkEncrypt_Req:
        {
            responseString = tempresponseString;   //response不加密
        }
            break;
        case TCTNetworkEncrypt_AES:
        {
            responseString = [NSString tc_aesDecryptAndBase64DecodeByCBD:tempresponseString withKey:self.encrypt.rspBodyAESKey];
        }
            break;
        case TCTNetworkEncrypt_AES_UnBody:
        {
            responseString = tempresponseString;   //response不加密
        }
            break;
        default: break;
    }
    
    if ([[TCTNetworkEngineConfig shareInstance].networkDebug isLogResponse]) {
        
        [self logResponseJson:operation responseString:responseString options:options];
                                                    
        if ([responseString length] <= 0) {
            //当前是否因为无网络没有返回数据
            if ([self isReachable]) {
                NSDebugLog(@"TCTNetworkEngine Tip:接口未返回正确数据");
            }
            else {
                NSDebugLog(@"TCTNetworkEngine Tip:当前网络无法请求数据");
            }
        }
    }
    
    id returnObject = nil;
    if (responseString.length > 0) {
        
        NSData *JSONData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
        
        if (JSONDictionary)
        {
            NSDictionary *bodyDictionary = nil;
            NSDictionary *headDictionary = JSONDictionary[@"header"];
            
            /*获取更新服务器时间*/
            if([headDictionary.allKeys containsObject:@"serverTime"]){
                NSString *serverTime = headDictionary[@"serverTime"];
                [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkingReceivedServiceTimeNotification object:nil userInfo:@{@"ServiceTime": serverTime}];
            }
            
            NSString *className = options[TCTResponseEntityName];
            //转对象 ----   缓存数据不做验证,提前return
            if (!operation && [self isNeedResponseDataCacheRequest:request]) {
                bodyDictionary = JSONDictionary[@"body"];//获取缓存中未解密的data
                //跳过数据验证
                Class c = NSClassFromString(className);
                returnObject = [c tc_objectWithDictionary:bodyDictionary];
                
                return returnObject;
            }
            
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;
            NSDictionary *allHeaderFields = response.allHeaderFields;
            //返回类型必须相等，否则为篡改
            NSString *bodyEncryptMD5String = [self.encrypt HTTPRspDataWithParameterString:tempresponseString];
            NSString *rspData = allHeaderFields[@"reqdata"];
            BOOL isValid = [rspData isEqualToString:bodyEncryptMD5String];  //数据验证
            
            //响应返回的加密类型
            TCTNetworkEncryptType type = ((NSString *)allHeaderFields[@"sec-ver"]).integerValue;
            
            //20150309 兼容可能存在的问题，对响应数据不执行sec-ver和reqdata签名校验
            if ([rspData isEqualToString:self.encrypt.rspDataDisabledKey] &&
                [self.encrypt.rspDataDisabledKey length] > 0) {
                encryptType = TCTNetworkEncrypt_Req;
            }   //20150317 增加有验证但未验证通过的通知，返回options
            else if ((encryptType != type || type != TCTNetworkEncrypt_None) && !isValid) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkEngineValidResponseErrorNotification object:options];
            }
            
            //当rspType为0时，可以获取body。
            //当rspType为1时，没有body。
            NSString *sRspType = [headDictionary objectForKey:@"rspType"];
            NSString *sRspCode = [headDictionary objectForKey:@"rspCode"];

            if ([sRspType isEqualToString:@"0"] && [sRspCode integerValue] == 0)//可以获取body
            {
                if (JSONDictionary[@"body"]) {
                    //根据加密类型强制判断，防止响应被篡改
                    switch (encryptType)
                    {
                        case TCTNetworkEncrypt_None:
                        {
                            isValid = YES;
                            bodyDictionary = JSONDictionary[@"body"];   //Body不加密
                        }
                            break;
                        case TCTNetworkEncrypt_Req:
                        {
                            isValid = YES;
                            bodyDictionary = JSONDictionary[@"body"];   //Body不加密
                        }
                            break;
                        case TCTNetworkEncrypt_AES:
                        {
                            if (isValid && type == TCTNetworkEncrypt_AES) {
                                bodyDictionary = JSONDictionary[@"body"];   //Body加密
                            }
                        }
                            break;
                        case TCTNetworkEncrypt_AES_UnBody:
                        {
                            if (isValid && type == TCTNetworkEncrypt_AES_UnBody) {
                                bodyDictionary = JSONDictionary[@"body"];   //Body不加密
                            }
                        }
                            break;
                        default: break;
                    }
                    
           
                    //debug状态打印Response_Log
                    if ([[TCTNetworkEngineConfig shareInstance].networkDebug isLogResponse]) {
//                        NSString *debug_responseString = nil;
                        switch (encryptType) {
                            case TCTNetworkEncrypt_None:
                            case TCTNetworkEncrypt_Req:
                            case TCTNetworkEncrypt_AES_UnBody:
                            {
//                                debug_responseString = responseString;
                            }
                                break;
                            case TCTNetworkEncrypt_AES:
                            {
                            }
                                break;
                            default: break;
                        }
                        //NSDebugLog(@"TCTNetworkEngine Tip:responseString is\n%@", debug_responseString);
                    }
                    
                    
                    if (isValid) {//数据验证通过
                        if (bodyDictionary && [bodyDictionary isKindOfClass:[NSDictionary class]]) {
                            Class c = NSClassFromString(className);
                            returnObject = [c tc_objectWithDictionary:bodyDictionary];
                        }
                        else {
                            returnObject = NSClassFromString(className).new;
                        }
                    }
                    else {//数据验证未通过
                        NSInteger rspCode = -1;
                        NSString *errorDescription = @"加载失败";
                        TCTErrorNetworkCallback errorType = TCTErrorNetworkResponseValidFail;
                        
                        TCTNetworkError *error = [TCTNetworkError errorWithDomain:@"responseObjectWithOperation" code:errorType userInfo:@{TCTNetworkErrorDescription : errorDescription}];
                        error.rspCode = rspCode;
                        error.entityName = className;
                        
                        return error;
                    }
                } else {
                    //请求成功，但是没有body
                    return nil;
                }
            }
            else//没有body
            {
                NSInteger rspCode = [headDictionary[@"rspCode"] intValue];
                NSString *errorDescription = [[headDictionary[@"rspDesc"] componentsSeparatedByString:@"|"] firstObject] ?: @"";
                if (rspCode == 7000) {
                    errorDescription = @"服务器偷懒了，先去其他页面逛逛吧";
                }
                
                TCTErrorNetworkCallback errorType = TCTErrorNetworkCallbackFailWithInterface;
                if (!isValid) errorType = TCTErrorNetworkResponseValidFail;
                
                TCTNetworkError *error = [TCTNetworkError errorWithDomain:@"responseObjectWithOperation" code:errorType userInfo:@{TCTNetworkErrorDescription : errorDescription}];
                
                error.rspCode = rspCode;
                error.entityName = className;
                
                //20190710 by Jabir 无需判断，json因为已解密
                bodyDictionary = JSONDictionary[@"body"];
                if (bodyDictionary && [bodyDictionary isKindOfClass:[NSDictionary class]]) {
                    error.rspObject = [NSClassFromString(className) tc_objectWithDictionary:bodyDictionary];
                }
                
                //对于错误返回也需要解密20151123 by Jabir
//                switch (encryptType) {
//                    case TCTNetworkEncrypt_Req:
//                        break;
//                    case TCTNetworkEncrypt_AES:
//                    {
//                        bodyDictionary = JSONDictionary[@"body"];
//                        if (bodyDictionary && [bodyDictionary isKindOfClass:[NSDictionary class]]) {
//                            error.rspObject = [NSClassFromString(className) tc_objectWithDictionary:bodyDictionary];
//                        }
//                    }
//                        break;
//                    case TCTNetworkEncrypt_AES_UnBody:
//                    {
//                        if (bodyDictionary && [bodyDictionary isKindOfClass:[NSDictionary class]]) {
//                            error.rspObject = [NSClassFromString(className) tc_objectWithDictionary:bodyDictionary];
//                        }
//                    }
//                        break;
//                    default: break;
//                }
                
                return error;
            }
        }
    }
    else {
        if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
            NSDebugLog(@"TCTNetworkEngine Tip:%@接口响应未返回JSON", options[TCTRequestServiceName]);
            //[NSException raise:NSInvalidArgumentException format:@"联系maxfong排查"];
        }
    }
    return returnObject;
}


#pragma mark - Log
- (void)logResponseJson:(NSURLSessionDataTask *)operation responseString:(NSString *)responseString options:(NSDictionary *)options{
    
    responseString = [[[[[[[[[responseString stringByReplacingOccurrencesOfString:@",\"" withString:@", \\\n                \""]
            stringByReplacingOccurrencesOfString:@"{" withString:@"{\\\n                "]
           stringByReplacingOccurrencesOfString:@"}," withString:@"\\\n            },"]
          stringByReplacingOccurrencesOfString:@"},{" withString:@"},\\\n            {"]
         stringByReplacingOccurrencesOfString:@"}}" withString:@"\\\n    }\\\n}"]
        stringByReplacingOccurrencesOfString:@"[{" withString:@"[\\\n            {"]
       stringByReplacingOccurrencesOfString:@"}]," withString:@"}\\\n        ],"]
      stringByReplacingOccurrencesOfString:@"\"}" withString:@"\"\\\n            }"]
     stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    if ([responseString containsString:@"                \"header\":{"]) {
        responseString =  [responseString stringByReplacingOccurrencesOfString:@"                \"header\":{"  withString:@"    \"header\":{"];
    }

    if ([responseString containsString:@"                \"body\":{"]) {
        responseString =  [responseString stringByReplacingOccurrencesOfString:@"                \"body\":{"  withString:@"    \"body\":{"];
    }
    
    NSDebugLog(@"TCTNetworkEngine Tip:\nResponse:\n URL is:  %@\nserviceName is:  %@\n%@\n", [operation.response.URL absoluteString],
               options[TCTRequestServiceName], responseString);
}

#pragma mark -
- (BOOL)cancelRequestWithKey:(NSString *)key
{
    if ([key length] > 0) {
        NSURLSessionDataTask *task = [self.requestQueue valueForKey:key];
        if (task) {
            [task cancel];
            [self removeRequestQueueWithKey:key];
            return YES;
        }
    }
    return NO;
}

- (void)removeRequestQueueWithKey:(NSString *)key
{
    if ([key length] > 0) {
        [self.requestQueue removeObjectForKey:key];
        [self.operationOptions removeObjectForKey:key];
        
        if (self.requestCount == 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
}

- (BOOL)cancelRequestWithKeys:(NSArray *)keys
{
    if ([keys isKindOfClass:[NSArray class]]) {
        __weak typeof(self) weakSelf = self;
        [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
         {
             [weakSelf cancelRequestWithKey:key];
         }];
        return YES;
    }
    return NO;
}

- (void)cancelAllRequest
{
    [self.requestQueue enumerateKeysAndObjectsUsingBlock:^(id key, NSURLSessionDataTask *task, BOOL *stop)
     {
         [task cancel];
     }];
    [self.requestQueue removeAllObjects];
    [self.operationOptions removeAllObjects];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
- (id)requestObjectWithKey:(NSString *)key
{
    NSDictionary *options = self.operationOptions[key];
    return options[TCTRequestEntityObject];
}

#pragma mark -
- (NSString *)responseClassNameWithRequest:(id<TCTRequestObjectDelegate>)request
{
    NSString *responseClassName = nil;
    if ([request respondsToSelector:@selector(ownResponseClassName)]) {
        responseClassName = [request ownResponseClassName];
    }
    else {
        NSString *requestClassName = NSStringFromClass([request class]);
        if ([requestClassName hasPrefix:kRequestClassPrefix])
        {
            responseClassName = [requestClassName stringByReplacingOccurrencesOfString:kRequestClassPrefix withString:kResponseClassPrefix];
        }
        else
        {
            if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
                NSDebugLog(@"TCTNetworkEngine Tip:请求%@类名未按开发规范定义", requestClassName);
                [NSException raise:NSInvalidArgumentException format:@"请联系maxfong排查"];
            }
        }
    }
    if (responseClassName && ![responseClassName hasPrefix:kResponseClassPrefix]) {
        if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
            NSDebugLog(@"TCTNetworkEngine Tip:响应%@类名未按开发规范定义", responseClassName);
            [NSException raise:NSInvalidArgumentException format:@"请联系maxfong排查"];
        }
    }
    return responseClassName;
}

- (NSString *)getSuccessDescription:(NSData *)data operation:(NSURLSessionDataTask *)operation options:(NSDictionary *)options{
    if (data) {
        NSString *tempresponseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *responseString = @"";
        
        //20190709 by Jabir
        //自定义加密类型-隐藏功能
        TCTNetworkEncryptType encryptType = self.encrypt.type;
        
        //20190709 Jabir修改，从下方挪到此处，从一开始解密就需要知道是否单独设置了加密类型
        TCTRequestObject *request = options[TCTRequestEntityObject];
        if ([request respondsToSelector:@selector(ownEncryptType)]) {
            encryptType = [request ownEncryptType];
        }
        
        //根据加密类型强制判断，防止响应被篡改
        switch (encryptType) {
            case TCTNetworkEncrypt_None:
            {
                responseString = tempresponseString;   //response不加密
            }
                break;
            case TCTNetworkEncrypt_Req:
            {
                responseString = tempresponseString;   //response不加密
            }
                break;
            case TCTNetworkEncrypt_AES:
            {
                responseString = [NSString tc_aesDecryptAndBase64DecodeByCBD:tempresponseString withKey:self.encrypt.rspBodyAESKey];
            }
                break;
            case TCTNetworkEncrypt_AES_UnBody:
            {
                responseString = tempresponseString;   //response不加密
            }
                break;
            default: break;
        }
        
        
//        responseString = [NSString tc_aesDecryptAndBase64DecodeByCBD:tempresponseString withKey:self.encrypt.rspBodyAESKey];

         #ifdef DEBUGMODEL
         NSAssert(responseString.length > 0, @"自定义断言:[TCTProtocolEngine getSuccessDescription:]异常-- serviceName is:  %@\ndata:%@\n\n\nDataStr:%@\nTCTNetworkEngine Tip:\nResponse:\n URL is:  %@\nkey:%@\n",options[TCTRequestServiceName],data, tempresponseString,[operation.response.URL absoluteString],responseString);
         #endif

        NSData *JSONData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        #ifdef DEBUGMODEL
        NSAssert(JSONData, @"自定义断言:[TCTProtocolEngine getSuccessDescription:]异常-- serviceName is:  %@\ndata:%@\n\n\nDataStr:%@\n\n\nJSONData:%@\nTCTNetworkEngine Tip:\nResponse:\n URL is:  %@\nkey:%@\n",options[TCTRequestServiceName],data,tempresponseString,JSONData, [operation.response.URL absoluteString], responseString);
        #endif
        
        if (JSONData) {
            NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *bodyDictionary = nil;
            if(JSONDictionary[@"body"])bodyDictionary = JSONDictionary[@"body"];
            return bodyDictionary[@"description"] ? bodyDictionary[@"description"] : @"";
        } else {
            return @"";
        }
      
    } else {
        return @"";
    }
}


@end

#pragma mark -
@implementation TCTProtocolEngine (NetworkReachabilityStatus)

- (void)startMonitoring {
    __weak typeof(self) weakSelf = self;
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager startMonitoring];
    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                strongSelf.networkReachabilityStatus = TCTNetworkReachabilityStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                strongSelf.networkReachabilityStatus = TCTNetworkReachabilityStatusNotReachable;
                [strongSelf notificationReachabilityChangeNoNetworkFromNotReachableToReachable];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                if (strongSelf.networkReachabilityStatus == TCTNetworkReachabilityStatusNotReachable) {
                    strongSelf.networkReachabilityStatus = TCTNetworkReachabilityStatusReachableViaWWAN;
                    [strongSelf notificationReachabilityChangeFromNotReachableToReachable];
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                if (strongSelf.networkReachabilityStatus == TCTNetworkReachabilityStatusNotReachable) {
                    strongSelf.networkReachabilityStatus = TCTNetworkReachabilityStatusReachableViaWiFi;
                    [strongSelf notificationReachabilityChangeFromNotReachableToReachable];
                }
                break;
            default:
                break;
        }
    }];
}

- (void)stopMonitoring {
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager stopMonitoring];
}

- (BOOL)isReachable {
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    return afNetworkReachabilityManager.reachable;
}

- (NSString *)stringFromNetworkReachabilityStatus {
    switch (self.networkReachabilityStatus) {
        case TCTNetworkReachabilityStatusUnknown:           return @"unknown";
        case TCTNetworkReachabilityStatusNotReachable:      return @"unreachable";
        case TCTNetworkReachabilityStatusReachableViaWiFi:  return @"wifi";
        case TCTNetworkReachabilityStatusReachableViaWWAN:  return @"wwan";
        default: break;
    }
    return @"unknown";
}

//通知网络 状态 无网 --> 有网
- (void)notificationReachabilityChangeFromNotReachableToReachable{
    // this makes sure the change notification happens on the MAIN THREAD
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkingChangeToNetworkReachabilityNotification object:nil userInfo:@{@"NetworkReachabilityStatus": [self stringFromNetworkReachabilityStatus]}];
//    });
    [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkingChangeToNetworkReachabilityNotification object:nil userInfo:@{@"NetworkReachabilityStatus": [self stringFromNetworkReachabilityStatus]}];
}

//通知网络 状态 有网  --> 无网
-(void)notificationReachabilityChangeNoNetworkFromNotReachableToReachable {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkingChangeToNoNetworkNotification object:nil userInfo:@{@"NetworkReachabilityStatus": [self stringFromNetworkReachabilityStatus]}];
//    });
    [[NSNotificationCenter defaultCenter] postNotificationName:TCTNetworkingChangeToNoNetworkNotification object:nil userInfo:@{@"NetworkReachabilityStatus": [self stringFromNetworkReachabilityStatus]}];
}

@end

@implementation TCTProtocolEngine (Extend)

static id exception(NSString *msg){
    [NSException raise:NSInvalidArgumentException format:@"%@, 联系maxfong排查", msg];
    return nil;
}

+ (instancetype)startWithBuilder:(TCTNetworkEngineBuildBlock)block
{
    NSParameterAssert(block);
    TCTNetworkEncrypt *encrypt = [[TCTNetworkEncrypt alloc] init];
    block(encrypt);
    
    //类型检查
    if (!encrypt.clientType) return exception(@"TCTNetworkEncrypt Tip:clientType未赋值");
    if (!encrypt.clientVersion) return exception(@"TCTNetworkEncrypt Tip:clientVersion未赋值");
    if (!encrypt.protocolVer) return exception(@"TCTNetworkEncrypt Tip:protocolVer未赋值");
    if (!encrypt.accountID) return exception(@"TCTNetworkEncrypt Tip:accountID未赋值");
    if (!encrypt.digitalSignPrivateKey) return exception(@"TCTNetworkEncrypt Tip:digitalSignPrivateKey未赋值");
    
    switch (encrypt.type) {
        case TCTNetworkEncrypt_Req:
        {
            if (!encrypt.reqDataKey) return exception(@"TCTNetworkEncrypt Tip:reqDataKey未赋值");
        } break;
        case TCTNetworkEncrypt_AES:
        {
            if (!encrypt.reqDataKey) return exception(@"TCTNetworkEncrypt Tip:reqDataKey未赋值");
            if (!encrypt.reqBodyAESKey) return exception(@"TCTNetworkEncrypt Tip:reqBodyAESKey未赋值");
            if (!encrypt.rspDataKey) return exception(@"TCTNetworkEncrypt Tip:rspDataKey未赋值");
            if (!encrypt.rspBodyAESKey) return exception(@"TCTNetworkEncrypt Tip:rspBodyAESKey未赋值");
        } break;
        case TCTNetworkEncrypt_AES_UnBody:
        {
            if (!encrypt.reqDataKey) return exception(@"TCTNetworkEncrypt Tip:reqDataKey未赋值");
            if (!encrypt.rspDataKey) return exception(@"TCTNetworkEncrypt Tip:rspDataKey未赋值");
        } break;
        default: break;
    }
    
    return [[TCTProtocolEngine alloc] initWithEncrypt:encrypt];
}



@end
