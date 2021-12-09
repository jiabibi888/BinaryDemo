//
//  TCTNetworkEncrypt+Handle.h
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTNetworkEncrypt.h"

@class TCTProtocolEngine;

@interface TCTNetworkEncrypt (Handle)

- (NSString *)HTTPRspDataWithParameterString:(NSString *)parameterString;
- (NSString *)HTTPReqDataWithParameterString:(NSString *)parameterString;
- (NSString *)encryptStringWithParameterString:(NSString *)parameterString withSign:(NSString *)sign;

@end
