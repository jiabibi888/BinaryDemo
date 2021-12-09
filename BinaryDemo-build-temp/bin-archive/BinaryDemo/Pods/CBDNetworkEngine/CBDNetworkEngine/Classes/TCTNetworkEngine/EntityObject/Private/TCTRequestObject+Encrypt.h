//
//  TCTRequestObject+Encrypt.h
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTRequestObject.h"

@class TCTNetworkEncrypt;

@interface TCTRequestObject (Encrypt)

/** 获取网络协议引擎 */
- (TCTProtocolEngine *)protocolEngine;

/** 获取加密requestKey */
- (NSString *)requestEncryptKey;

/** 先获取ownParamsDictionary，无结果再返回tc_propertyDictionary */
- (NSMutableDictionary *)propertyValueDictionary;

/** 传给中间层的JSONString */
- (NSString *)requestJSONStringWithEncrypt:(TCTNetworkEncrypt *)encrypt;


@end
