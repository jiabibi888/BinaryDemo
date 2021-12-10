//
//  NSString+NetworkEngineReplace.m
//  TCTNetworkEngine
//
//  Created by maxfong on 15/3/24.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "NSString+NetworkEngineReplace.h"

@implementation NSString (NetworkEngineReplace)

+ (NSString *)tc_replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options replaceArray:(NSArray *)replaceArray_
{
    if (!target) return nil;
    NSMutableString *tempStr = [NSMutableString stringWithString:target];
    NSArray *replaceArray = [NSArray arrayWithArray:replaceArray_];
    for(int i = 0; i < [replaceArray count]; i++){
        NSRange range = [target rangeOfString:[replaceArray objectAtIndex:i]];
        if(range.location != NSNotFound){
            [tempStr replaceOccurrencesOfString:[replaceArray objectAtIndex:i]
                                     withString:replacement
                                        options:options
                                          range:NSMakeRange(0, [tempStr length])];
        }
    }
    return tempStr;
}

@end
