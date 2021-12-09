//
//  NSString+NetworkEngineReplace.h
//  TCTNetworkEngine
//
//  Created by maxfong on 15/3/24.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NetworkEngineReplace)

/**
 *  字符串筛选,去掉不需要的特殊字符串
 *  使用方法:cbd_replaceOccurrencesOfString:@"1(2*3" withString:@"" options:2 replaceArray:[NSArray arrayWithObjects:@"(",@"*", nil]
 输出:123
 *
 *  @param target        原字符串
 *  @param replacement   需要替换的字符串
 *  @param options       默认传2:NSLiteralSearch,区分大小写
 *  @param replaceArray 需要排除的Array
 *
 *  @return 筛选后的字符串
 */
+ (NSString *)tc_replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options replaceArray:(NSArray *)replaceArray;

@end
