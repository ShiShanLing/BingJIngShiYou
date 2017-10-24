//
//  NSObject+BJShiYou.m
//  BJShiYou
//
//  Created by vstyle on 16/3/8.
//  Copyright (c) 2016年 com.vstyle. All rights reserved.
//

#import "NSObject+BJShiYou.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>

@implementation NSObject (BJShiYou)



- (NSString *)toJSON {
    NSError *error;
    NSData *datas = [NSJSONSerialization dataWithJSONObject:self
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:&error];
    return [[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
}

-(NSData*)toJSONData
{
    NSError *error;
    NSData *datas = [NSJSONSerialization dataWithJSONObject:self
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:&error];
    
    
    return datas;
}
@end
@implementation Is


+ (BOOL)EmptyOrNullString:(NSString *)str {
    
    if (str == nil) return YES;
    
    if ([str isEqual:[NSNull null]]) return YES;
    
    if (![str isKindOfClass:[NSString class]]) return NO;
    
    return str.length == 0 || [str isEqualToString:@"<null>"];
}
@end
@implementation Network
+ (int)getNetworkStatus{
    // 状态栏是由当前app控制的，首先获取当前app
    UIApplication *app = [UIApplication sharedApplication];

    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];

    int type = 0;
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
            }
    }
    /*
     NETWORN_NONE = 0;//没有连接
     NETWORN_WIFI = 1;//连接的wifi
     NETWORN_2G = 2;//2G网络连接
     NETWORN_3G = 3;//3G网络连接
     NETWORN_4G = 4;//4G网络连接
     NETWORN_MOBILE=5;//手机热点
     
     0   -   无网络 ;   1   -   2G ;   2   -   3G ;   3   -   4G ;   5   -   WIFI
     */
    int networkStatus;
    switch (type) {
        case 0:
        {
            networkStatus = 0;//没有连接
        }
             break;
        case 1:
        {
            networkStatus = 2;//2G网络连接
        }
             break;
            break;
        case 2:
        {
            networkStatus = 3;//3G网络连接
        }
             break;
            break;
        case 3:
        {
            networkStatus = 4;//4G网络连接
        }
             break;
        case 5:
        {
            networkStatus = 1;//连接的wifi
        }
            break;
        default:
        {
            networkStatus = 5;//手机热点
        }
            break;
    }
    return networkStatus;
}


@end
@implementation File
//单个文件的大小

+ (long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        
    }
    
    return 0;
    
}
//遍历文件夹获得文件夹大小，返回多少M

+ (float )folderSizeAtPath:(NSString*) folderPath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:folderPath]) return 0;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString* fileName;
    
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        
        folderSize += [File fileSizeAtPath:fileAbsolutePath];
        
    }
    
    return folderSize/(1024.0*1024.0);
    
}
@end