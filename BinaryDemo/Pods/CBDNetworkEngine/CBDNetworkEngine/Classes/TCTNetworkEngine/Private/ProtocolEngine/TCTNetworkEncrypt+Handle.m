//
//  TCTNetworkEncrypt+Handle.m
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTNetworkEncrypt+Handle.h"
#import "NSString+NetworkEngineEncrypt.h"

@implementation TCTNetworkEncrypt (Handle)

/** Encrypt */
- (NSString *)HTTPReqDataWithParameterString:(NSString *)parameterString
{
    return [self encryptStringWithParameterString:parameterString withSign:self.reqDataKey];
}

- (NSString *)HTTPRspDataWithParameterString:(NSString *)parameterString
{
    return [self encryptStringWithParameterString:parameterString withSign:self.rspDataKey];
}

- (NSString *)encryptStringWithParameterString:(NSString *)parameterString withSign:(NSString *)sign
{
    return [[NSString stringWithFormat:@"%@%@", parameterString, sign] tc_MD5EncodedString];
}

@end
