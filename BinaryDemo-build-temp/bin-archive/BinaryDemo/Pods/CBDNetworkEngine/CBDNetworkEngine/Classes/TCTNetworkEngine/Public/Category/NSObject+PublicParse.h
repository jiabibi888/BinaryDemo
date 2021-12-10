//
//  NSObject+PublicParse.h
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCTNetworkEngineElementProtocol.h"

@interface NSObject (PublicParse)

/** 获取当前对象的属性集合 */
- (NSDictionary *)propertyDictionary;
/** 根据数据集合生成对象 */
+ (id<TCTNetworkEngineElementProtocol>)objectWithDictionary:(NSDictionary *)dictionary;

/** 获取类属性列表，不包含父类 */
+ (NSArray *)propertyNames;
/** 属性列表截止自己设置的类，一般cls传入类的superClass */
+ (NSArray *)propertyNamesUntilClass:(Class)cls;
/** 每获取propertyName运行Block一次 */
+ (NSArray *)propertyNamesUntilClass:(Class)cls usingBlock:(void (^)(NSString *propertyName))block;

@end
