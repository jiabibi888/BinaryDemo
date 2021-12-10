//
//  TCTResponseObject.h
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//
//

#import <Foundation/Foundation.h>

@interface TCTResponseObject : NSObject

/**
 *  将参数属性合并到当前对象
 *
 *  @param pName    属性名称
 *  @param rObject  源对象
 *
 *  Dictionary&Array属性，存在则合并值，不存在则赋值
 *  String属性，覆盖原值
 *
 *  @return 错误类型
 */
- (void)combineProperty:(NSString *)pName fromObject:(TCTResponseObject *)rObject withError:(NSError **)error;
- (void)combineObject:(TCTResponseObject *)rObject withError:(NSError **)error;

@end
