//
//  NSObject+PublicParse.m
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "NSObject+PublicParse.h"
#import "NSObject+NetworkEngineParse.h"

@implementation NSObject (PublicParse)

- (NSDictionary *)propertyDictionary {
    return [self tc_propertyDictionary];
}

+ (id)objectWithDictionary:(NSDictionary *)dictionary {
    return [self tc_objectWithDictionary:dictionary];
}

+ (NSArray *)propertyNames {
    return [self propertyNamesUntilClass:[self class]];
}

+ (NSArray *)propertyNamesUntilClass:(Class)cls {
    return [self propertyNamesUntilClass:cls usingBlock:nil];
}

+ (NSArray *)propertyNamesUntilClass:(Class)cls usingBlock:(void (^)(NSString *propertyName))block
{
    return [self tc_propertyNamesUntilClass:cls usingBlock:block];
}
@end
