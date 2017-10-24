//
//  DatabaseOperations.h
//  BJShiYou
//
//  Created by vstyle on 15/11/11.
//  Copyright (c) 2015年 com.vstyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseOperations : NSObject
/**
 根据name插入value
 */
+(void)insertDataWithName:(NSString *)name withValue:(NSString *)value;
/**
 根据name删除数据
 */
+(void)deleteDataWithName:(NSString *)name;
/**
 根据name更新某条数据
 */
+(void)updateDataWithName:(NSString *)name withValue:(NSString *)value;
/**
 获取用户
 */
+(NSDictionary *)getUser;
/**
 获取数据库所有数据
 */
+(NSArray *)getAll;
/**
 清除用户数据
 */
+(void)clearUser;
/**
 保存用户数据
 */
+(void)saveUserWithUserName:(NSString *)name WithUserPassWord:(NSString *)passWord;
/**
 根据name查询数据，返回这条数据的所有信息
 */
+(NSDictionary *)selectValueWhithName:(NSString *)name;
/**
 根据name查询数据，只返回结果
 */
+(NSString *)selectValueWhithSingleName:(NSString *)name;


//通知开关
/**
 设置通知打开
 */
+(void)setNotifyOpenWithVale:(NSString *)notifyValue;
/**
 设置通知关闭
 */
+(void)setNotifyCloseWithVale:(NSString *)notifyValue;
/**
 获取通知状态
 */
+(NSString *)getNotifyState;

/**
 根据表名判断表是否存在
 */
+(BOOL)isTableExistWithTableName:(NSString *)tableName;
/**
 获取数据库地址
 */
+(NSString *)getDbPath;
/**
 存储身份信息
 */
+ (void)setExtparamWithString:(NSString *)extpatam;
/**
 删除身份信息
 */
+ (void)deleteExtparam;
/**
 获取身份信息
 */
+ (NSString *)getExtparam;

/**
 存储WebService地址
 */
+ (void)setWebServiceURL:(NSString *)serviceURL;
/**
 删除WebService地址
 */
+ (void)deleteWebServiceURL;
/**
 获取WebService地址
 */
+ (NSString *)getWebServiceURL;
@end
