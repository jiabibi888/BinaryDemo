//
//  TCTNetworkEngineKeyValueProtocol.h
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//
//

#import <Foundation/Foundation.h>

/*  已弃用，修正为replacedElementDictionary
 */
#define TCTElementDictionaryFromDictionary(dictionary) \
if ([self respondsToSelector:NSSelectorFromString(@"_elementDictionary_max")])\
{ [[self valueForKey:@"_elementDictionary_max"] addEntriesFromDictionary:dictionary]; }

@protocol TCTNetworkEngineElementProtocol <NSObject>

@optional
/*  帮助你快速设置接口同客户端对象映射表(解决接口返回相同对象的问题)
 key:   中间层接口字段命名
 value: 客户端对象命名
 */
+ (NSDictionary *)replacedElementDictionary;

@end
