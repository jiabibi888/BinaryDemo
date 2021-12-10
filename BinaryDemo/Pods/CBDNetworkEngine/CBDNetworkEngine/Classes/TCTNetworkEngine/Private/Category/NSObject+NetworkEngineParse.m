//
//  NSObject+NetworkEngineParse.m
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-8.
//
//

#import "NSObject+NetworkEngineParse.h"
#import "TCTNetworkEngineConfig.h"
#import "TCTNetworkDebug.h"
#import <objc/runtime.h>
#import "TCFoundation.h"

static char const *ElementDictionary = "ElementDictionary";

@implementation NSObject (NetworkEngineParse)

#pragma mark - 节点转换
- (NSMutableDictionary *)_elementDictionary_max
{
    if (!objc_getAssociatedObject(self, ElementDictionary)) {
        objc_setAssociatedObject(self, ElementDictionary, [@{} mutableCopy], OBJC_ASSOCIATION_RETAIN);
    }
    return objc_getAssociatedObject(self, ElementDictionary);
}

#pragma mark - 根据数据集合&类型，获取对象
+ (id)tc_objectWithDictionary:(NSDictionary *)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    Class rspClass = [self class];
    id responseObject = rspClass.new;
#ifdef DEBUG
    if (!responseObject) {
        if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
            NSDebugLog(@"TCTNetworkEngine Tip:验证%@类是否创建或@implementation是否实现", NSStringFromClass(rspClass));
            [NSException raise:NSInvalidArgumentException format:@"联系maxfong排查"];
        }
    }
#endif
    if ([dictionary count] <= 0) return responseObject;
    [rspClass tc_propertyNamesUntilClass:[NSObject class] usingBlock:^(NSString *propertyName) {
        id propertyValue = dictionary[propertyName];
        if (propertyValue && ![propertyValue isKindOfClass:[NSNull class]]) {//null防御 by dj
            if ([propertyValue isKindOfClass:[NSDictionary class]]) {
                objc_property_t theProperty = class_getProperty([responseObject class], [propertyName UTF8String]);
                char *propertyType = property_copyAttributeValue(theProperty, "T");
                id propertyObject = nil;
                //此处是为了增强代码健壮性，增加判断，防止字符串截取挂掉
                if ((propertyType != NULL) && (propertyType[0] == '@') && (strlen(propertyType) >= 3)) {
                    char *cClassName = strndup(propertyType+2, strlen(propertyType)-3);
                    NSString *keyClassName = [NSString stringWithCString:cClassName encoding:NSUTF8StringEncoding];
#ifdef DEBUG
                    if ([[TCTNetworkEngineConfig shareInstance].networkDebug isDebug]) {
                        if ([keyClassName hasSuffix:@"Array"] && ![propertyName hasSuffix:@"Array"]) {
                            NSDebugLog(@"TCTNetworkEngine Tip:验证%@属性的类型是否正确", propertyName);
                            [NSException raise:NSInvalidArgumentException format:@"联系maxfong排查"];
                        }
                    }
#endif
                    Class cls = NSClassFromString(keyClassName);
                    propertyObject = cls ? [cls tc_objectWithDictionary:propertyValue] : propertyValue;
                    //释放 property_copyAttributeValue / strndup 函数  解决网络请求内存泄露问题  __LZQ_2.4
                    free(propertyType);
                    free(cClassName);
                }
                else {
                    Class cls = NSClassFromString(propertyName);
                    propertyObject = cls ?[cls tc_objectWithDictionary:propertyValue] : propertyValue;
                }
                [responseObject setValue:propertyObject forKey:propertyName];
            }
            else if ([propertyValue isKindOfClass:[NSArray class]]) {
                NSString *propertyClassName = nil;
                if ([responseObject respondsToSelector:@selector(_elementDictionary_max)]) {
                    propertyClassName = [responseObject valueForKey:@"_elementDictionary_max"][propertyName];
                }
                if ([self respondsToSelector:@selector(replacedElementDictionary)]) {
                    NSDictionary *replacedDictionary = [self performSelector:@selector(replacedElementDictionary)];
                    propertyClassName = replacedDictionary[propertyName];
                }
                propertyClassName = propertyClassName ?: propertyName;
                Class cls = NSClassFromString(propertyClassName);
                id propertyObject = cls ? [cls tc_objectWithArray:propertyValue] : propertyValue;
                [responseObject setValue:propertyObject forKey:propertyName];
            }
            else
            {
                [responseObject setValue:propertyValue forKey:propertyName];
            }
        }
    }];
    return responseObject;
}

+ (id)tc_objectWithArray:(NSArray *)array
{
    NSMutableArray *propertyArray = [@[] mutableCopy];
    if ([array isKindOfClass:[NSArray class]]) {
        for (id obj in array) {
            id propertyValue = nil;
            if ([obj isKindOfClass:[NSDictionary class]]) {
                propertyValue = [self tc_objectWithDictionary:obj];
            }
            else if ([obj isKindOfClass:[NSArray class]]) {
                propertyValue = [self tc_objectWithArray:obj];
            }
            else propertyValue = obj;
            if (propertyValue) [propertyArray addObject:propertyValue];
        }
    }
    return propertyArray;
}

#pragma mark - 获取当前对象的属性集合
- (NSDictionary *)tc_propertyDictionary
{
    __block NSMutableDictionary *dictionary = [@{} mutableCopy];
    
    [[self class] tc_propertyNamesUntilClass:[self class] usingBlock:^(NSString *propertyName) {
        id propertyValue = [self valueForKey:propertyName];
        if(propertyValue) {
            id value = nil;
            if ([propertyValue isKindOfClass:[NSObject class]]) {
                if ([propertyValue isKindOfClass:[NSArray class]]) {
                    value = [propertyValue tc_propertyArray];
                }
                else if ([propertyValue isKindOfClass:[NSNumber class]] ||
                         [propertyValue isKindOfClass:[NSString class]]) {
                    value = propertyValue;
                }
                else if ([propertyValue isKindOfClass:[NSNull class]]) {//null防御 by dj
                    value = nil;
                }
                else {
                    value = [propertyValue tc_propertyDictionary];
                }
            }
            [dictionary setValue:value forKey:propertyName];
        }
    }];
    return dictionary;
}

- (NSArray *)tc_propertyArray
{
    __block NSMutableArray *propertyArray = [@[] mutableCopy];
    if ([self isKindOfClass:[NSArray class]]) {
        [(NSArray *)self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id propertyValue = nil;
            if ([obj isKindOfClass:[NSArray class]]) {
                propertyValue = [obj tc_propertyArray];
            }
            else if ([obj isKindOfClass:[NSString class]]) {
                propertyValue = obj;
            }
            else {
                propertyValue = [obj tc_propertyDictionary];
            }
            if (propertyValue) [propertyArray addObject:propertyValue];
        }];
    }
    return propertyArray;
}

#pragma mark - 对象的属性列表
+ (NSArray *)tc_propertyNamesUntilClass:(Class)sCls usingBlock:(void (^)(NSString *propertyName))block {
    Class cls = [self class];
    NSMutableArray *mArray = [@[] mutableCopy];
    while ((cls != [NSObject class]) && (cls != [sCls superclass]) &&(cls != [NSNull class])) {//null防御 by dj
        unsigned propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
        for ( int i = 0 ; i < propertyCount ; i++ ) {
            objc_property_t property = properties[i];
            NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            if (propertyName) [mArray addObject:propertyName];
            if (block) block(propertyName);
        }
        cls = [cls superclass];
        free(properties);
    }
    return mArray;
}

#pragma mark - 合并属性
- (void)tc_combineProperty:(NSString *)pName fromObject:(NSObject *)object withError:(NSError **)error
{
    id newValue = nil; NSString *errMessage = nil;
    if ([object respondsToSelector:NSSelectorFromString(pName)]) {
        newValue = [object valueForKey:pName];
    }
    else errMessage = [NSString stringWithFormat:@"TCTNetworkEngine Tip:%@无%@属性", NSStringFromClass([object class]), pName];
    id oldValue = nil;
    if (newValue && [self respondsToSelector:NSSelectorFromString(pName)]) {
        oldValue = [self valueForKey:pName];
        id finishValue = nil;
        if ([oldValue isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mDictionary = [@{} mutableCopy];
            [mDictionary addEntriesFromDictionary:newValue];
            [mDictionary addEntriesFromDictionary:oldValue];
            finishValue = mDictionary;
        }
        else if ([oldValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *mArray = [@[] mutableCopy];
            [mArray addObjectsFromArray:newValue];
            [mArray addObjectsFromArray:oldValue];
            finishValue = mArray;
        }
        else {
            finishValue = newValue;
        }
        [self setValue:finishValue forKey:pName];
    }
    else errMessage = [NSString stringWithFormat:@"TCTNetworkEngine Tip:%@无%@属性", NSStringFromClass([self class]), pName];
    if (errMessage && error) {
        *error = [NSError errorWithDomain:@"combineProperty:fromObject:withError:" code:0 userInfo:@{@"description" : errMessage}];
    }
}

- (void)tc_combineObject:(NSObject *)object withError:(NSError **)error
{
    [[self class] tc_propertyNamesUntilClass:[NSObject class] usingBlock:^(NSString *propertyName) {
        [self tc_combineProperty:propertyName fromObject:object withError:error];
        if (error) return;
    }];
}

@end
