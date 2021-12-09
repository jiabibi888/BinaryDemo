//
//  TCTNetworkError.h
//  TCTNetworkEngine
//
//  Created by maxfong on 15/1/16.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TCTNetworkErrorDescription;

typedef NS_ENUM(NSUInteger, TCTErrorNetworkCallback) {
    TCTErrorNetworkCallbackUnKnown = -1,        ///未知
    TCTErrorNetworkCallbackCancel = 0,          ///取消
    TCTErrorNetworkCallbackUnReachable,         ///无网络
    TCTErrorNetworkCallbackFailWithServer,      ///服务器连接失败
    TCTErrorNetworkCallbackFailWithInterface,   ///接口失败
    TCTErrorNetworkResponseValidFail
};

@interface TCTNetworkError : NSError

/** 接口状态非0000，但是JSON对象可解析 */
@property (nonatomic, strong) id rspObject;
/** 接口Code */
@property (nonatomic, assign) NSInteger rspCode;

@property (nonatomic, strong) NSString *entityName;

@end

