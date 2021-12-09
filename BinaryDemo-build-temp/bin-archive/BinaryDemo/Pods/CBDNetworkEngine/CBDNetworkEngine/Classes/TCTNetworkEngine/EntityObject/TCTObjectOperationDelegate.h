//
//  TCTObjectOperationDelegate.h
//  TCTNetworkEngine
//
//  Created by maxfong on 14-10-8.
//
//

#import <Foundation/Foundation.h>

@protocol TCTObjectOperationDelegate <NSObject>

/** 开始操作 */
- (void)start;

/** 取消操作 */
- (void)cancel;

- (NSString *)objectIdentifier;

@end
