//
//  NSObject+NetworkEngineParse.h
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-8.
//
//

#import <Foundation/Foundation.h>
#import "TCTNetworkEngineElementProtocol.h"

@interface NSObject (NetworkEngineParse) <TCTNetworkEngineElementProtocol>

/** 获取当前对象的属性集合 */
- (NSDictionary *)tc_propertyDictionary;

/**
 *  根据数据集合&类型，获取对象
 *
 *  @param dictionary 数据集合
 *  @param className  类型，建议使用NSStringFromClass(cls)
 *
 *  @return 对象实例
 */
+ (id)tc_objectWithDictionary:(id)dictionary;

/** 获取当前对象的属性列表，截至NSObject */
+ (NSArray *)tc_propertyNamesUntilClass:(Class)cls usingBlock:(void (^)(NSString *propertyName))block;

/**
 *  合并属性
 *
 *  @param pName    属性名称
 *  @param object   源对象
 *
 *  Dictionary&Array属性，存在合并值，不存在赋值
 *  String属性，覆盖原值
 *
 *  @return 错误类型
 */
- (void)tc_combineProperty:(NSString *)pName fromObject:(NSObject *)object withError:(NSError **)error;
- (void)tc_combineObject:(NSObject *)object withError:(NSError **)error;

@end
