//
//  TCTIdentifier.m
//  TCTNetworkEngine
//
//  Created by maxfong on 15-01-01.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTIdentifier.h"
#import <UIKit/UIDevice.h>
#import <AdSupport/AdSupport.h>
#import "TCTKeyChain.h"
#import "OpenUDID.h"
#import "TCTNetworkEngineConfig.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "TCTIPAddress.h"
#import <sys/utsname.h>
#import "TCFoundation.h"

static NSString * const kDeviceIdKey = @"deviceId";

@implementation TCTIdentifier

+ (NSString *)advertisingId
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 ) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return @"";
}

+ (NSString *)deviceId
{
    NSString *keyChain_Key = [TCTNetworkEngineConfig networkConfit_TCTNetworkEngine_KeyChain_Key] ? : @"";
    NSString *deviceId = [TCTKeyChain objectForKey:keyChain_Key];
    if ([deviceId length] <= 0)
    {
        deviceId = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceIdKey];
        if ([deviceId length] <= 0)
        {
            NSString *openUDID = [[TCT_OpenUDID value] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            if ([openUDID length] > 0)
            {
                deviceId = openUDID;
            }
            else {
                NSString *advertisingId = [self advertisingId];
                if ([advertisingId length] > 0) {
                    deviceId = advertisingId;
                }
                else {
                    NSString *devicePushToken = [TCTNetworkEngineConfig networkConfit_TCTNetworkEngine_DevicePushToken] ?: @"";
                    
                    if ([devicePushToken length] > 0) {
                        deviceId = devicePushToken;
                    }
                    else {
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
                            deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                        }
                    }
                }
            }
            
            if ([deviceId length] > 0) {
                [TCTKeyChain setObject:deviceId forKey:keyChain_Key];
                
                [[NSUserDefaults standardUserDefaults] setValue:deviceId forKey:kDeviceIdKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    return deviceId ?: @"";
}

+ (NSString *)IP {
    return [TCTIPAddress IPAddress]?:@"";
}

+(NSString*)getADId
{
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return adId;
}

+ (NSString*)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSDebugLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSDebugLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

//返回设备型号，如果是最新的设备型号，如果不在这个返回，就返回identifier，根据对照表去找
//http://theiphonewiki.com/wiki/Models
+ (NSString *)currentDeviceModelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSDictionary *modelDic = @{
                               @"i386" : @"iPhone Simulator",
                               @"x86_64" : @"iPhone Simulator" ,
                               
                               @"iPhone1,1" : @"iPhone2G" ,
                               @"iPhone1,2" :  @"iPhone3G",
                               @"iPhone2,1" :  @"iPhone3GS",
                               @"iPhone3,1" : @"iPhone4" ,
                               @"iPhone3,2" :  @"iPhone4",
                               @"iPhone3,3" :  @"iPhone4",
                               @"iPhone4,1" :  @"iPhone4S",
                               @"iPhone5,1" :  @"iPhone5" ,
                               @"iPhone5,2" :  @"iPhone5",
                               @"iPhone5,3" :  @"iPhone5c",
                               @"iPhone5,4" :  @"iPhone5c",
                               @"iPhone6,1" :  @"iphone5s",
                               @"iPhone6,2" :  @"iphone5s",
                               @"iPhone7,1" :  @"iphone6P",
                               @"iPhone7,2" :  @"iphone6",
                               @"iPhone8,1" :  @"iphone6s",
                               @"iPhone8,2" :  @"iphone6sP",
                               @"iPhone8,4" :  @"iphonese" ,
                               @"iPhone9,1" :  @"iphone7",
                               @"iPhone9,3" :  @"iphone7",
                               @"iPhone9,2" :  @"iphone7p",
                               @"iPhone9,4" :  @"iphone7p",
                               @"iPhone10,1" : @"iPhone 8" ,
                               @"iPhone10,4" :  @"iPhone 8",
                               @"iPhone10,2" :  @"iPhone 8 Plus",
                               @"iPhone10,5" :  @"iPhone 8 Plus",
                               @"iPhone10,3" :  @"iPhone X",
                               @"iPhone10,6" : @"iPhone X" ,
                               @"iPhone11,8" :  @"iPhone XR",
                               @"iPhone11,2" : @"iPhone XS" ,
                               @"iPhone11,4" :  @"iPhone XS Max",
                               @"iPhone11,6" : @"iPhone XS Max",
                               @"iPhone12,1" : @"iPhone 11",
                               @"iPhone12,3" : @"iPhone 11 Pro",
                               @"iPhone12,5" : @"iPhone 11 Pro Max",
                               @"iPhone12,8" : @"iPhone SE2",
                               @"iPhone13,1" : @"iPhone 12 mini",
                               @"iPhone13,2" : @"iPhone 12",
                               @"iPhone13,3" : @"iPhone 12 Pro",
                               @"iPhone13,4" : @"iPhone 12 Pro Max",
                               
                               @"iPod1,1" :  @"iPod Touch 1G" ,
                               @"iPod2,1" :  @"iPod Touch 2G",
                               @"iPod3,1" :  @"iPod Touch 3G",
                               @"iPod4,1" :  @"iPod Touch 4G",
                               @"iPod5,1" :  @"iPod Touch 5G",
                               
                               @"iPad1,1" :  @"iPad",
                               @"iPad2,1" :  @"iPad 2(WiFi)",
                               @"iPad2,2" :  @"iPad 2(GSM)",
                               @"iPad2,3" :  @"iPad 2(CDMA)",
                               @"iPad2,4" :  @"iPad 2(WiFi + New Chip)",
                               @"iPad3,1" :  @"iPad 3(WiFi)",
                               @"iPad3,2" :  @"iPad 3(GSM+CDMA)",
                               @"iPad3,3" :  @"iPad 3(GSM)",
                               @"iPad3,4" :  @"iPad 4(WiFi)",
                               @"iPad3,5" :  @"iPad 4(GSM)",
                               @"iPad3,6" :  @"iPad 4(GSM+CDMA)",
                               @"iPad4,1" :  @"iPad Air(WiFi)",
                               @"iPad4,2" :  @"iPad Air(LTE 4G)",
                               @"iPad4,3" :  @"iPad Air(TD-LTE)" ,
                               @"iPad5,3" :  @"iPad Air 2(WiFi)",
                               @"iPad5,4" :  @"iPad Air 2(WiFi+Cellular)",
                               @"iPad6,3" :  @"iPad Pro(9.7-inch)",
                               @"iPad6,4" :  @"iPad Pro(9.7-inch)",
                               @"iPad6,7" :  @"iPad Pro(12.9-inch)",
                               @"iPad6,8" :  @"iPad Pro(12.9-inch)",
                               @"iPad6,11" :  @"iPad(5th generation)",
                               @"iPad6,12" :  @"iPad(5th generation)",
                               @"iPad7,1" :  @"iPad Pro(12.9-inch,2nd generation)",
                               @"iPad7,2" :  @"iPad Pro(12.9-inch,2nd generation)",
                               @"iPad7,3" :  @"iPad Pro(10.5-inch)",
                               @"iPad7,4" :  @"iPad Pro(10.5-inch)",
                               @"iPad7,5" :  @"iPad Pro(6th generation)",
                               @"iPad7,6" :  @"iPad Pro(6th generation)",
                               
                               @"iPad2,5" :  @"iPad mini (WiFi)",
                               @"iPad2,6" :  @"iPad mini (GSM)",
                               @"iPad2,7" :  @"ipad mini (GSM+CDMA)",
                               @"iPad4,4" :  @"iPad mini 2(WiFi)",
                               @"iPad4,5" :  @"iPad mini 2(LTE 4G)",
                               @"iPad4,6" :  @"iPad mini 2(TD-LTE)",
                               @"iPad4,7" :  @"iPad mini 3(WiFi)",
                               @"iPad4,8" :  @"iPad mini 3(WiFi+Cellular)",
                               @"iPad4,9" :  @"iPad mini 3(TD-LTE)",
                               @"iPad5,1" :  @"iPad mini 4",
                               @"iPad5,2" :  @"iPad mini 4"
                               };
    
    NSString *modelNameString = @"";
    NSArray *keys = modelDic.allKeys;
    if([keys containsObject:deviceString]){
      NSInteger  modelIndex = [keys indexOfObject:deviceString];
        if (modelIndex >= 0 && modelIndex < [keys count]) {
            modelNameString = [modelDic objectForKey:keys[modelIndex]];
        }else{
            modelNameString =[deviceString stringByAppendingString:@"(machine值，需要对照表)"];
        }
    }

    return modelNameString;
}

@end
