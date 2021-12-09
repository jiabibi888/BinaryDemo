#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CBDPromptConst.h"
#import "CBDPublicEnum.h"
#import "TCFoundation.h"

FOUNDATION_EXPORT double CBDConfigVersionNumber;
FOUNDATION_EXPORT const unsigned char CBDConfigVersionString[];

