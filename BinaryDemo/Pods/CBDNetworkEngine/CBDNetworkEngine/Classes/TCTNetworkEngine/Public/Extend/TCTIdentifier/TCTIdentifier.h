//
//  TCTIdentifier.h
//  TCTNetworkEngine
//
//  Created by maxfong on 15-01-01.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCTIdentifier : NSObject

/** advertisingId */
+ (NSString *)advertisingId;

/** 获取设备标识符 */
+ (NSString *)deviceId;

+(NSString*)getADId;

/** 获取设备当前IP */
+ (NSString *)IP;

+ (NSString*)getMacAddress;

/// 设备型号名称，如果是最新的设备型号，如果不在这个返回，就返回identifier，根据对照表去找
+ (NSString *)currentDeviceModelName;
@end
