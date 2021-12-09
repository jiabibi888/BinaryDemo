//
//  TCTKeyChain.h
//  TCTNetworkEngine
//
//  Created by maxfong on 15-01-01.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCTKeyChain : NSObject

/** 保存 */
+ (void)setObject:(id)anObject forKey:(NSString*)key;

/** 获取 */
+ (id)objectForKey:(NSString *)key;

/** 移除 */
+ (void)removeObjectForKey:(NSString *)key;

@end
