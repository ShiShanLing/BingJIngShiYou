//
//  DatabaseOperations.m
//  BJShiYou
//
//  Created by vstyle on 15/11/11.
//  Copyright (c) 2015年 com.vstyle. All rights reserved.
//

#import "DatabaseOperations.h"
#import "FMDatabase.h"
#import "NSObject+BJShiYou.h"
#import "Header.h"

@implementation DatabaseOperations

+(void)insertDataWithName:(NSString *)name withValue:(NSString *)value{//添加数据

    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    [db executeUpdate:@"INSERT INTO PersonList (name,value,time) VALUES (?,?,?)",name,value,[self getTime]];
    [db close];
}
+(void)deleteDataWithName:(NSString *)name{//删除数据
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    [db executeUpdate:@"delete from PersonList where name = ?",name];
    [db close];
}
+(void)updateDataWithName:(NSString *)name withValue:(NSString *)value{//更新数据
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    [db setShouldCacheStatements:YES];
    [db executeUpdate:@"update PersonList set value = ? where name = ?",value,name];
    [db close];
}

+(NSDictionary *)getUser{//获取用户数据
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    NSString *idValue = nil;
    NSString *userName = nil;
    NSString *passWord = nil;
    NSString *timeStr = nil;
    FMResultSet *sName = [db executeQuery:@"SELECT * from PersonList where name = 'domino_username'"];
    while ([sName next]) {

        NSString *idvalue =[sName stringForColumn:@"id"];
        idValue = idvalue;
//            NSString *name=[s stringForColumn:@"name"];
        NSString *data=[sName stringForColumn:@"value"];
        userName = data;
        NSString *time = [sName stringForColumn:@"time"];
        timeStr = time;
//        DLog(@"%@\n%@\n%@",idvalue,data,time);
    }
    
    FMResultSet *s = [db executeQuery:@"SELECT * from PersonList where name = 'domino_password'"];
    while ([s next]) {
        NSString *idvalue =[s stringForColumn:@"id"];
        idValue = idvalue;
        //            NSString *name=[s stringForColumn:@"name"];
        NSString *data=[s stringForColumn:@"value"];
        passWord = data;
        NSString *time = [s stringForColumn:@"time"];
        timeStr = time;
//        DLog(@"%@\n%@\n%@",idvalue,data,time);
    }
    if ([Is EmptyOrNullString:idValue] || [Is EmptyOrNullString:userName] || [Is EmptyOrNullString:passWord] || [Is EmptyOrNullString:timeStr]) {
        return nil;
    }
    NSDictionary *dict = @{@"id":idValue,@"userName":userName,@"password":passWord,@"time":timeStr};
    [db close];
    NSLog(@"%@ %id", [db close]?@"用户信息提取成功":@"用户信息提取失败",[db close]);
    return dict;
}
+(NSArray *)getAll{//获取数据库所有数据
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    NSMutableArray*array = [[NSMutableArray alloc] init];
    NSDictionary *dict;
    FMResultSet *sName = [db executeQuery:@"SELECT * from PersonList"];
    while ([sName next]) {
        
        NSString *idvalue =[sName stringForColumn:@"id"];
        NSString *name=[sName stringForColumn:@"name"];
        NSString *data=[sName stringForColumn:@"value"];
        NSString *time = [sName stringForColumn:@"time"];
        dict = @{@"id":idvalue,@"name":name,@"value":data,@"time":time};
        [array addObject:dict];
    }
    return array;
}
+(void)clearUser{//清除用户
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    [db executeUpdate:@"delete from PersonList where name = 'domino_username'"];
    [db executeUpdate:@"delete from PersonList where name = 'domino_password'"];
    [db close];
}
+(void)saveUserWithUserName:(NSString *)name WithUserPassWord:(NSString *)passWord{//保存用户
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    [db executeUpdate:@"INSERT INTO PersonList (name,value,time) VALUES (?,?,?)",@"domino_username",name,[self getTime]];
    [db executeUpdate:@"INSERT INTO PersonList (name,value,time) VALUES (?,?,?)",@"domino_password",passWord,[self getTime]];
     [db close];
    NSLog(@"%@ %id", [db close]?@"用户信息保存成功":@"用户信息保存失败",[db close]);
    
}
+(NSDictionary *)selectValueWhithName:(NSString *)name{//查询单条数据(返回整条数据)
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    NSMutableArray*array = [[NSMutableArray alloc] init];
    NSDictionary *dict;
    FMResultSet *sName = [db executeQuery:@"SELECT * from PersonList where name = ?",name];
    while ([sName next]) {
        
        NSString *idvalue =[sName stringForColumn:@"id"];
        NSString *name=[sName stringForColumn:@"name"];
        NSString *data=[sName stringForColumn:@"value"];
        NSString *time = [sName stringForColumn:@"time"];
        dict = @{@"id":idvalue,@"name":name,@"value":data,@"time":time};
    }
    return dict;
}
+(NSString *)selectValueWhithSingleName:(NSString *)name{//查询单条数据(只返回值不返回整条数据)
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    NSString *value = nil;
    FMResultSet *sName = [db executeQuery:@"SELECT * from PersonList where name = ?",name];
    while ([sName next]) {
        NSString *data=[sName stringForColumn:@"value"];
        value = data;
    }
    return value;
}
#pragma mark - 通知类
+(void)setNotifyOpenWithVale:(NSString *)notifyValue{
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    [db executeUpdate:@"delete from PersonList where name = 'petroleum_notify_key'"];
    [db executeUpdate:@"INSERT INTO PersonList (name,value,time) VALUES (?,?,?)",@"petroleum_notify_key",notifyValue,[self getTime]];
    [db close];
}
+(void)setNotifyCloseWithVale:(NSString *)notifyValue{
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    [db executeUpdate:@"update PersonList set value = ? where name = ?",notifyValue,@"petroleum_notify_key"];
    [db close];
}
+(NSString *)getNotifyState{
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    [db open];
    NSString *value = nil;
    FMResultSet *sName = [db executeQuery:@"SELECT * from PersonList where name = 'petroleum_notify_key'"];
    while ([sName next]) {
        NSString *data=[sName stringForColumn:@"value"];
        value = data;
    }
    return value;
}

+ (void)setExtparamWithString:(NSString *)extpatam{
    [self deleteDataWithName:@"setExtparam"];
    [self insertDataWithName:@"setExtparam" withValue:extpatam];
}
+ (void)deleteExtparam{
    [self deleteDataWithName:@"setExtparam"];
}
+ (NSString *)getExtparam{
    NSString *extparam = [self selectValueWhithSingleName:@"setExtparam"];
    return extparam;
}

+ (void)setWebServiceURL:(NSString *)serviceURL{
    [self deleteDataWithName:@"WebServiceUrl"];
    [self insertDataWithName:@"WebServiceUrl" withValue:serviceURL];
}
+ (void)deleteWebServiceURL{
    [self deleteDataWithName:@"WebServiceUrl"];
}
+ (NSString *)getWebServiceURL{
    NSString *webServiceUrl = [self selectValueWhithSingleName:@"WebServiceUrl"];
    return webServiceUrl;
}

+(NSString *)getDbPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.sqlite"];
    return dbPath;
}
+(NSString *)getTime{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}
//根据表的名字判断表是否存在
+(BOOL)isTableExistWithTableName:(NSString *)tableName
{
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    if (![db open]) {
        return NO;
    }
    FMResultSet *set = [db executeQuery:@"select count(*) as count from sqlite_master where type = 'table' and name = ?",tableName];
    if ([set next]) {
        NSInteger count = [set intForColumn:@"count"];
        if (0 == count) {
            [db close];
            return NO;
        }
        [db close];
        return YES;
    }
    [db close];
    return NO;
}
@end
