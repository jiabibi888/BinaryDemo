//
//  TCTNetworkError.m
//  TCTNetworkEngine
//
//  Created by maxfong on 15/1/16.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTNetworkError.h"

NSString *const TCTNetworkErrorDescription = @"TCTNetworkErrorDescription";

@implementation TCTNetworkError

- (NSString *)description {
    return self.userInfo[TCTNetworkErrorDescription];
}

@end
