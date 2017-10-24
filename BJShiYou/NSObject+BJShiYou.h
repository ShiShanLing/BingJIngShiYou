//
//  NSObject+BJShiYou.h
//  BJShiYou
//
//  Created by vstyle on 16/3/8.
//  Copyright (c) 2016年 com.vstyle. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AFNetworking.h"

@interface NSObject (BJShiYou)
-(NSString *) toJSON;
- (NSData *)toJSONData;
@end
@interface  Is :NSObject

+(BOOL)EmptyOrNullString:(NSString *)str;
@end

@interface  Network :NSObject
+ (int)getNetworkStatus;
@end

@interface  File :NSObject
+ (long long) fileSizeAtPath:(NSString*) filePath;
+ (float )folderSizeAtPath:(NSString*) folderPath;
@end