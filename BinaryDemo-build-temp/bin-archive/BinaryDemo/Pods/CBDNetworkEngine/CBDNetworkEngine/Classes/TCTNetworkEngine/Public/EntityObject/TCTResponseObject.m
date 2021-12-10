//
//  TCTResponseObject.m
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//
//

#import "TCTResponseObject.h"
#import "NSObject+NetworkEngineParse.h"

@implementation TCTResponseObject

- (void)combineProperty:(NSString *)propertyName fromObject:(TCTResponseObject *)responseObject withError:(NSError **)error {
    [self tc_combineProperty:propertyName fromObject:responseObject withError:error];
}

- (void)combineObject:(TCTResponseObject *)responseObject withError:(NSError **)error {
    [self tc_combineObject:responseObject withError:error];
}

@end
