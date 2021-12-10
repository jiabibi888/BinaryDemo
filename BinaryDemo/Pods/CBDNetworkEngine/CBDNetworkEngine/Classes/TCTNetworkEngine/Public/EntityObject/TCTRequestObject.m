//
//  TCTRequestObject.m
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-8.
//
//  需要完成：1.调试加密的值，隐藏属性提供解密的response。2.参数缓存的问题，避免多次执行加密

#import "TCTRequestObject+Encrypt.h"
#import "NSObject+NetworkEngineParse.h"
#import "TCTNetworkEncrypt.h"
//static const void * PrivateKVOContext;

@interface TCTRequestObject ()

@property (nonatomic, assign, readwrite) BOOL cancelled;
@property (nonatomic, assign, readwrite) BOOL executing;

@property (nonatomic, strong, readwrite) NSString *objectIdentifier;

@end

@implementation TCTRequestObject
@synthesize cacheKey = _cacheKey;

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.needReconnection = YES;
    }
    return self;
}
- (void)start {
    [[self protocolEngine] sendRequest:self];
    self.executing = YES;
    self.cancelled = NO;
}

- (void)cancel {
    if (self.executing) {
        [[self protocolEngine] cancelRequestWithKey:self.objectIdentifier];
        self.executing = NO;
        self.cancelled = YES;
    }
}

- (BOOL)isExecuting {
    _executing = [[self protocolEngine] requestObjectWithKey:self.objectIdentifier] ? YES : NO;
    return _executing;
}


/**
 自动响应数据缓存 请求发起

 @param success success
 @param fail fail
 @param key key   --
                                   1.非订单详情页建议使用统一前缀格式: 请求实体名_当前控制器(或页面名称)  eg:RequestGetOrderList_OrderListViewController_1  ---  避免重复
                                   2.订单详情页使用订单流水号 或其他唯一标识即可
 */
- (void)startAndCacheWithSuccessBlock:(TCTRequestSuccessBlock)success failBlock:(TCTRequestFailBlock)fail  cacheKey:(NSString *)key{
    self.successBlock = success;
    self.failBlock = fail;
    self.needCache = YES;
    self.cacheKey = key;
    [self start];
}

- (void)startWithSuccessBlock:(TCTRequestSuccessBlock)success failBlock:(TCTRequestFailBlock)fail {
    self.successBlock = success;
    self.failBlock = fail;
    [self start];
}

- (void)clearCompletionBlock {
    self.successBlock = nil;
    self.failBlock = nil;
    self.executing = NO;
}

#pragma mark - objectIdentifier
- (NSString *)objectIdentifier {
    if (!_objectIdentifier) {
        _objectIdentifier = [self requestEncryptKey];
        //赋值后，key根据属性改变
        [self addObserver:self forKeyPath:@"objectIdentifier" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _objectIdentifier;
}

+ (NSSet *)keyPathsForValuesAffectingObjectIdentifier {
    NSArray *propertyNames = [self tc_propertyNamesUntilClass:[self class] usingBlock:nil];
    return [NSSet setWithArray:propertyNames];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"objectIdentifier"]) {
        _objectIdentifier = [self requestEncryptKey];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    @try {
        if (_objectIdentifier) {
            [self removeObserver:self forKeyPath:@"objectIdentifier"];
        }
    }
    @catch (NSException *exception) {
    }
}

@end

@implementation TCTRequestObject (PublicEncrypt)

- (NSString *)requestJSONString {
    return [self requestJSONStringWithEncrypt:({
        TCTNetworkEncrypt *encrypt = TCTNetworkEncrypt.new;
        [encrypt tc_combineObject:self.protocolEngine.encrypt withError:nil];
        encrypt.type = TCTNetworkEncrypt_Req;
        encrypt; })];
}

@end
