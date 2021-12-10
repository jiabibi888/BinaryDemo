//
//  TCTNetworkDebug.h
//  TCTNetworkEngine
//
//  Created by maxfong on 15/1/1.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCTNetworkDebug : NSObject

/** 开启Debug后，错误信息会被打印，默认NO */
@property (nonatomic, assign, getter = isDebug) BOOL debug;
/** 打印request JSON，默认NO */
@property (nonatomic, assign, getter = isLogRequest) BOOL logRequest;
/** 打印response JSON，默认NO */
@property (nonatomic, assign, getter = isLogResponse) BOOL logResponse;
/** 接口请求错误，post TCTNetworkingInterfaceServiceErrorNotification，默认NO */
@property (nonatomic, assign, getter = isSaveClientLog) BOOL saveClientLog;

///** 单例对象 */
//+ (id)sharedManager;

@end
