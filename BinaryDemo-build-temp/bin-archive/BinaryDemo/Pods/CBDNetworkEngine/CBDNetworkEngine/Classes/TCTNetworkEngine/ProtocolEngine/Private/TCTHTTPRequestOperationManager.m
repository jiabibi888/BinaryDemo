//
//  TCTHTTPRequestOperationManager.m
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-8.
//
//

#import "TCTHTTPRequestOperationManager.h"
#import "TCTNetworkEncrypt+Handle.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TCFoundation.h"
#import "TCTIdentifier.h"
#import "TCTKeyChain.h"
#import <CommonCrypto/CommonDigest.h>
#import <pthread.h>
#import "TCTNetworkEngineConfig.h"

static NSString *CBDRequestCacheFolderName = @"CBDRequestCache";
//响应缓存key字典
static NSString *const kCarBaDa_ResponseCacheKeys = @"CarBaDa_ResponseCacheKeys";

static NSUInteger TCTRequestTimeoutInterval = 30;     //30s

@interface TCTHTTPRequestOperationManager (){
    pthread_mutex_t _lock; //Vic:互斥锁 : 引入保证文件操作线程的同步性
   
}

@property (nonatomic, strong) dispatch_queue_t fileOperationQueue;

@end

@implementation TCTHTTPRequestOperationManager

- (void)dealloc{
    pthread_mutex_destroy(&_lock);
}

- (dispatch_queue_t)fileOperationQueue
{
    if (!_fileOperationQueue) {
        _fileOperationQueue = dispatch_queue_create("com.17u.TCTHTTPRequestOperationManagerQueue", DISPATCH_QUEUE_CONCURRENT);
        
        pthread_mutex_init(&_lock, NULL);
    }
    return _fileOperationQueue;
}

- (nullable NSURLSessionDataTask *)POST:(nullable NSString *)URLString
                             parameters:(nullable id)parameters
                                success:(nullable void (^)(NSURLSessionDataTask *_Nullable task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError* _Nullable error))failure
                                encrypt:(nullable TCTNetworkEncrypt *)encrypt
                          cacheResponse:(BOOL)cacheResponse
                               cacheKey:(nullable NSString *)cacheKey
                            serviceName:(NSString*)sName
{
    NSError *serializationError = nil;
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [self setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [self.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
        return parameters;
    }];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    [request setValue:@(encrypt.type).stringValue forHTTPHeaderField:@"sec-ver"];
    NSString *reqEncryptData = [encrypt HTTPReqDataWithParameterString:parameters];
    [request setValue:reqEncryptData forHTTPHeaderField:@"reqdata"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"chebada/ios" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"zh-CN" forHTTPHeaderField:@"Accept-Language"];
    if ([TCTNetworkEngineConfig cbdSecurity].length > 0) {
        [request setValue:[TCTNetworkEngineConfig cbdSecurity] forHTTPHeaderField:@"security"];
    }
    
    [request setValue:sName forHTTPHeaderField:@"S-Name"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    //增加风控参数
    //版本号
    [request setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"av"];
    //唯一码
    NSString *sDid = [TCTKeyChain objectForKey:@"requestDid"];
    if (sDid.length <= 0) {
        sDid = [TCTIdentifier deviceId];
        [TCTKeyChain setObject:sDid forKey:@"requestDid"];
    }
    
    [request setValue:sDid forHTTPHeaderField:@"did"];
    
    [self.requestSerializer setTimeoutInterval:TCTRequestTimeoutInterval];
    
//Vic: 网络缓存
//    if (cacheResponse && cacheKey.length > 0 && [CBDConfigureManager shareInstance].acquireNetworkStatus == NotReachable) {//是否有缓存  缓存是否有效
//        id responseData = [self unarchiveResponseDataWithKey:cacheKey];
//        if (responseData) {
//            if (success) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^(void) {
//                    success(nil, responseData);
//                });
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self showCacheAlertView];
//                });
//            }
//            return nil;
//        }
//    }
    
    //    需求变成 只要是失败就取缓存
//Vic: 没有/不使用网络缓存  --  则发出请求
    __block NSURLSessionDataTask *dataTask = nil;
    __weak __typeof(self)weakSelf = self;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:nil
                        downloadProgress:nil
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           
                           /* -cancel returns immediately, but marks a task as being canceled.
                            * The task will signal -URLSession:task:didCompleteWithError: with an
                            * error value of { NSURLErrorDomain, NSURLErrorCancelled }.  In some
                            * cases, the task may signal other work before it acknowledges the
                            * cancelation.  -cancel may be sent to a task that has been suspended.
                            */
                           //- (void)cancel;
                           
                           if (error ) {
                               if( !([error.domain isEqualToString: NSURLErrorDomain] && error.code == NSURLErrorCancelled)){//排除取消的请求
                                   //需求变成 只要是失败就取缓存
                                   //  使用缓存 超时 error.code == NSURLErrorTimedOut  &&
                                   if( cacheResponse && cacheKey.length > 0){
                                       id responseData = [weakSelf unarchiveResponseDataWithKey:cacheKey];
                                       if (responseData) {
                                           if (success) {
                                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^(void) {
                                                   success(nil, responseData);
                                               });
                                               
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [weakSelf showCacheAlertView];
                                               });
                                               
                                               return;
                                           }
                                       }
                                   }
                               }
                               
                               
                               if (failure) {
                                   failure(dataTask, error);
                               }
                               
                           } else {
                               if (success) {
                                   success(dataTask, responseObject);
                               }
                           }
                       }];
    
    [dataTask resume];
    
    return dataTask;
}



- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {
    
    return [super dataTaskWithRequest:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:completionHandler];
}


#pragma mark - 缓存处理
/**Vic:
 缓存处理:
               反归档缓存
 */
- (id)unarchiveResponseDataWithKey:(NSString *)key
{
    if ([key length] > 0) {
        NSString *cacheFileName = [self cacheFileNameWithKey:key];
       
        BOOL bHave = [[NSFileManager defaultManager] fileExistsAtPath:cacheFileName];
        if (bHave) {//Vic: 文件存在
            
            NSDictionary *arrtibutes = [[NSFileManager defaultManager] attributesOfItemAtPath:cacheFileName error:nil];
            if (arrtibutes) {
                NSDate *createDate = arrtibutes[NSFileCreationDate];//获取 data
                if (createDate) {
                    id responseData = [NSKeyedUnarchiver unarchiveObjectWithFile:cacheFileName];
                    return responseData ? : nil;// 获取缓存Task
                }
                
                //Vic: data不存在 或  已失效
                dispatch_async(self.fileOperationQueue, ^{
                    pthread_mutex_lock(&_lock);
                    [[NSFileManager defaultManager] removeItemAtPath:cacheFileName error:nil];// 移除
                    pthread_mutex_unlock(&_lock);
                });
            }
        }
       
    }
    return nil;
}

/**Vic:
 缓存处理 :
          缓存归档
 */
- (void)archiveResponseData:(id )responseData withKey:(NSString *)key{
    
    if ([key length] > 0 && responseData) {
        NSString *cacheFileName = [self cacheFileNameWithKey:key];
        //如果对同一个路径下的同一个文件进行归档操作，就会覆盖掉旧的
        dispatch_async(self.fileOperationQueue, ^{
            pthread_mutex_lock(&_lock);
           BOOL state =  [NSKeyedArchiver archiveRootObject:responseData toFile:cacheFileName];
            pthread_mutex_unlock(&_lock);
            
            if(state){
                NSDebugLog(@"缓存写入/更新成功");
                [self manageCacheArrayAddWithKey:key];
            }
          
        });
            
    }
}

#pragma mark - 维护缓存文件名数组  -- 暂无应用
/**Vic:
 维护缓存文件名数组:
                                       添加
 */
- (void)manageCacheArrayAddWithKey:(NSString *)key{
    if ([self tct_objectForKey:kCarBaDa_ResponseCacheKeys] && key.length > 0){
        NSString *cacheFileName = [self cacheFileNameWithKey:key];
        //读
        NSArray *arrCacheInfo = (NSArray *)[self tct_objectForKey:kCarBaDa_ResponseCacheKeys];
        if (![arrCacheInfo containsObject:cacheFileName]) {
            //改
            NSMutableArray *tempArr = [[NSMutableArray alloc]initWithArray:(NSArray *)arrCacheInfo];//修改缓存数据
            [tempArr addObject:cacheFileName];
            //存
            NSArray *newUserCache = [NSArray arrayWithArray:tempArr];//转为不可变 存储
            [self tct_setValue:newUserCache forKey:kCarBaDa_ResponseCacheKeys];
            
//            for (NSString *key in newUserCache) {
//                NSDebugLog(@"%@", key);
//            }
            
        }

    }else{//首次
        if (key.length > 0) {
            NSString *cacheFileName = [self cacheFileNameWithKey:key];
            NSArray *arrCreatCache = [[NSArray alloc] initWithObjects:cacheFileName, nil];
            [self tct_setValue:arrCreatCache forKey:kCarBaDa_ResponseCacheKeys];
        }
    }
}

/**Vic:
 维护缓存文件名数组:
                                       删除
 */
- (void)manageCacheArrayDeleteWithKey:(NSString *)key{
    if ([self tct_objectForKey:kCarBaDa_ResponseCacheKeys] && key.length > 0){
        NSString *cacheFileName = [self cacheFileNameWithKey:key];
        //读
        NSArray *arrCacheInfo = (NSArray *)[self tct_objectForKey:kCarBaDa_ResponseCacheKeys];
        if ([arrCacheInfo containsObject:cacheFileName]) {
            //改
            NSMutableArray *tempArr = [[NSMutableArray alloc]initWithArray:(NSArray *)arrCacheInfo];//修改缓存数据
            [tempArr removeObject:cacheFileName];
            //存
            NSArray *newUserCache = [NSArray arrayWithArray:tempArr];//转为不可变 存储
            [self tct_setValue:newUserCache forKey:kCarBaDa_ResponseCacheKeys];
            
//            for (NSString *key in newUserCache) {
//                NSDebugLog(@"%@", key);
//            }
        }
    }
}

/**Vic:
 维护缓存文件名数组:
                                    清空
 */
- (void)manageCacheArrayClear{
    if ([self tct_objectForKey:kCarBaDa_ResponseCacheKeys] ){
      NSArray *emptyArr = [[NSArray alloc]init];
      [self tct_setValue:emptyArr forKey:kCarBaDa_ResponseCacheKeys];
        
//        NSArray *arrCacheInfo = (NSArray *)[NSUserDefaults tct_objectForKey:CarBaDa_ResponseCacheKeys];
//        NSDebugLog(@"%ld", arrCacheInfo.count);
    }
}

#pragma mark - 缓存文件操作
/**Vic:
 缓存文件操作:
         单个缓存文件清理
 */
- (void)clearTheResponseCacheWithFileName:(NSString *)key{
    NSString *cacheFileName = [self cacheFileNameWithKey:key];
    BOOL bHave = [[NSFileManager defaultManager] fileExistsAtPath:cacheFileName];
    if(bHave) {
        pthread_mutex_lock(&_lock);
        BOOL blDele= [[NSFileManager defaultManager] removeItemAtPath:cacheFileName error:nil];
        pthread_mutex_unlock(&_lock);
        if (blDele) {
            [self manageCacheArrayDeleteWithKey:key];
            NSDebugLog(@"key:%@  单个缓存文件清理成功", key);
        }else {
            NSDebugLog(@"key:%@  单个缓存文件清理失败", key);
        }
    }else{
        return;
    }
}

/**Vic:
  缓存文件操作:
                         清空
                                 --  清理最上层文件夹
 */
- (void)clearResponseDataCache{
    BOOL isDirectory;//isDirectory用来判断是文件夹还是文件，如果路径不存在，返回为undefined，表示不能确定
    BOOL bHave = [[NSFileManager defaultManager] fileExistsAtPath:[self cachePath] isDirectory:&isDirectory];
    if (!bHave) {
        return;
    }else {
        if(isDirectory){
            dispatch_async(self.fileOperationQueue, ^{
                pthread_mutex_lock(&_lock);
                BOOL blDele= [[NSFileManager defaultManager] removeItemAtPath:[self cachePath] error:nil];
                pthread_mutex_unlock(&_lock);
            
                if (blDele) {
                    [self manageCacheArrayClear];
                    NSDebugLog(@"网络缓存顶层文件清空成功 - - 网络数据缓存全部清空");
                }else {
                    NSDebugLog(@"网络缓存顶层文件清空失败 -- 路径%@", [self cachePath]);
                }
                
            });
        }
    }
}

#pragma mark - 沙盒相关
/**Vic:
 沙盒相关 :
                 沙盒路径
 */
- (NSString *)cachePath{
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];//沙盒
    NSString *path = [NSString stringWithFormat:@"%@/%@", cachesDirectory, CBDRequestCacheFolderName];
    if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        //不存在创建文件夹  顶层文件
        NSError * _Nullable error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error) {
            NSDebugLog(@"create cache directory failed, error = %@", error);
        }
    }
    return path;
}

/**Vic:
 沙盒相关:
               自定义拼接单个文件路径
 */
- (NSString *)cacheFileNameWithKey:(NSString *)key{
    //memberId  + key
    NSString *customPath = [NSString stringWithFormat:@"%@%@", [TCTNetworkEngineConfig cbdSecurity], key];
    
    return [[self cachePath] stringByAppendingPathComponent:[self MD5Securit:customPath]];
}

/**Vic:
 沙盒相关:
      文件名 MD5  -- 任意长度的数据，算出的MD5值长度都是固定的
           -- 生成唯一的128位散列值（32个字符），即 32个16进制的数字
 */
- (NSString *)MD5Securit:(NSString *)string{
    //1
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    
    //2
    //任意长度的数据，算出的MD5值长度都是固定的
    //    const char *cStr = [string UTF8String];
    //    //buffer
    //    uint8_t result[CC_MD5_DIGEST_LENGTH];
    //
    //    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    //对输入信息生成唯一的128位散列值（32个字符），即 32个16进制的数字。
    
    
    //    return [NSString stringWithFormat:
    //            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
    //            result[0], result[1], result[2], result[3],
    //            result[4], result[5], result[6], result[7],
    //            result[8], result[9], result[10], result[11],
    //            result[12], result[13], result[14], result[15]
    //            ];
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

- (void)showCacheAlertView{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"网络不给力，您访问的是本地缓存数据" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:sureAction];
    UIViewController *currentVc = [self tct_getCurrentVC];
    [currentVc presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - Tools
- (UIViewController *)tct_getCurrentVC {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *currentVC = [self tct_getCurrentVCFrom:rootViewController];
    return currentVC;
}

- (UIViewController *)tct_getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self tct_getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self tct_getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

- (id)tct_objectForKey:(NSString*)sKey {
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:sKey];
    if (obj) {
        return obj;
    } else {
        return nil;
    }
}

- (void)tct_setValue:(id)value forKey:(NSString*)sKey {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:sKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
