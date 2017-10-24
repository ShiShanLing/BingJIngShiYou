//
//  AppDelegate.m
//  BJShiYou
//
//  Created by vstyle on 15/11/9.
//  Copyright (c) 2015年 com.vstyle. All rights reserved.
//

#import "AppDelegate.h"
#import "FMDatabase.h"
#import "DatabaseOperations.h"
#import "WebserviceObject.h"
#import "NSObject+BJShiYou.h"
#import "Header.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()<NSXMLParserDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>{
    NSTimer *timer;
    int myBadge;
    WebserviceObject *webServiceObj;
}
@property (nonatomic, strong)CLLocationManager * manager;

@end

@implementation AppDelegate

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    
    
    return UIInterfaceOrientationMaskPortrait;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

// 打印本地数据库地址
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    DLog(@"打印本地数据库地址 = %@", path);

    //1.获得数据库文件的路径
     NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
     NSString *fileName=[doc stringByAppendingPathComponent:@"MyDatabase.sqlite"];

     //2.获得数据库
     FMDatabase *db=[FMDatabase databaseWithPath:fileName];
     //3.打开数据库
     if ([db open]) {
         //4.创表
         if ([DatabaseOperations isTableExistWithTableName:@"PersonList"]) {
             
         }else{
             BOOL result=[db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE PersonList (id INTEGER PRIMARY KEY, name TEXT ,value TEXT ,time DATATIME not null)"]];
             if (result) {
                 DLog(@"创表成功");
             }else
             {
                 DLog(@"创表失败");
             }
         }
 }
//    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startWebservice) userInfo:nil repeats:YES];
    myBadge = 0;
    
    return YES;
}

- (void)startWebservice{
    
    static int a = 0;
    a++;
    DLog(@"%d",a);
    
    NSDictionary *userDict = [DatabaseOperations getUser];
    
    NSString *userName = userDict[@"userName"];
    NSString *passwordStr = userDict[@"password"];
    NSString *extpatamStr = [DatabaseOperations getExtparam];
    
    /*NSData *passwordData = [passwordStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *passwordJiami = [self base64EncodedStringFrom:passwordData];
    DLog(@"密码加密---------%@",passwordJiami);*/
    
    NSString *soapMsg = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> "
                         "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
                         "<soap12:Body>"
                         "<getTaskQueue xmlns=\"http://tempuri.org/\">"
                         "<appid>HSE_BEIJING_SINOPEC</appid>"
                         "<appsecret>orcDHBgaxw8b-o3r0ZX3mUJ_kHmpcDW_Ko7WJ4opaKnjnyPtkcfgAQPqb8A3XsBK</appsecret>"
                         "<username>%@</username>"
                         "<password>%@</password>"
                         "<extparam>%@</extparam>"
                         "</getTaskQueue>"
                         "</soap12:Body>"
                         "</soap12:Envelope>",userName,passwordStr,extpatamStr];
    
    NSString *urlStr;
    if (![Is EmptyOrNullString:[DatabaseOperations getWebServiceURL]]) {
        urlStr = [DatabaseOperations getWebServiceURL];
    }else{
//        urlStr = @"http://123.127.191.221:1000/Interface/msgPush.asmx?wsdl";
    }
    
    NSURL *url=[NSURL URLWithString:urlStr];
    
    NSString *msgLength=[NSString stringWithFormat:@"%lu",(unsigned long)[soapMsg length]];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    [request addValue: @"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSMutableString *result=[[NSMutableString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
//    DLog(@"获得结果是%@",result);
    // 1、取出<ns:return>和</ns:return>标签的位置
    NSRange rang01 = [result rangeOfString:@"<getTaskQueueResult>"];
    NSRange rang02 = [result rangeOfString:@"</getTaskQueueResult>"];
    if (rang01.location == NSNotFound || rang02.location == NSNotFound) {
        DLog(@"webService请求失败了！");
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(startWebservice) userInfo:nil repeats:YES];
    }else {
        NSUInteger subStrLocation = (rang01.location + rang01.length);
        NSRange subStrRange = NSMakeRange(subStrLocation, rang02.location - subStrLocation);
        
        // 2、取出有效部分的Text
        NSString *resultVaildStr = [result substringWithRange:subStrRange];
        NSDictionary *dict = [self parseJSONStringToNSDictionary:resultVaildStr];
        webServiceObj = [[WebserviceObject alloc] init];
        webServiceObj.isSuccess = [dict[@"success"] boolValue]; //YES;//
        webServiceObj.message = dict[@"message"];
        webServiceObj.content = dict[@"content"];//@"测试时间准确性";//
        webServiceObj.get_period = [dict[@"get_period"] integerValue];//60000;//
        webServiceObj.notice_number = [dict[@"notice_number"] integerValue];
        webServiceObj.blocking_timel = dict[@"blocking_timel"];
        webServiceObj.time = dict[@"time"];//@"2016-03-18 14:41:30";//
        webServiceObj.title = dict[@"title"];//@"北京石油";//
        webServiceObj.type = dict[@"type"];
        webServiceObj.url = dict[@"url"];//@"http://msptest.zjmicon.com/Own/Exam/myExamList.aspx";//
        
        if (webServiceObj.isSuccess && ![Is EmptyOrNullString:webServiceObj.content] && ![Is EmptyOrNullString:webServiceObj.title]) {
            [self registerLocalNotification:1.0f withWebServiceObj:webServiceObj];
        }
        [timer invalidate];
        if (webServiceObj.get_period) {
            DLog(@"%ld",(long)webServiceObj.get_period);
            timer = [NSTimer scheduledTimerWithTimeInterval:webServiceObj.get_period/1000.0f target:self selector:@selector(startWebservice) userInfo:nil repeats:YES];
        }else {
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startWebservice) userInfo:nil repeats:YES];
        }
    }
}



- (NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        DLog(@"失败=---------原因：%@",error);
        return nil;
    }
    return responseJSON;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // 更新显示的徽章个数
//    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
//    int badgeI = [[NSString stringWithFormat:@"%ld",badge] intValue];
//    badgeI--;
//    badgeI = badgeI >= 0 ? badgeI : 0;
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    myBadge = 0;
    if (![Is EmptyOrNullString:webServiceObj.url] && webServiceObj.isSuccess) {
//        NSDictionary *myDictionary = [NSDictionary dictionaryWithObject:webServiceObj.url forKey:@"url"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationUrl" object:myDictionary];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:webServiceObj.title
//                                                        message:webServiceObj.content
//                                                       delegate:self
//                                              cancelButtonTitle:@"取消"
//                                              otherButtonTitles:@"确定",nil];
//        [alert show];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 设置本地通知
- (void)registerLocalNotification:(NSInteger)alertTime withWebServiceObj:(WebserviceObject *)webServiceObject{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    

    //通知重复次数
    notification.repeatInterval=webServiceObj.notice_number;
    //应用程序图标右上角显示的消息数
//    notification.applicationIconBadgeNumber = 1;
    //待机界面的滑动动作提示
    notification.alertAction = @"打开应用";
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
    DLog(@"fireDate=%@",fireDate);
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = kCFCalendarUnitSecond;
    
    // 通知内容
    notification.alertBody =  webServiceObj.content;//webServiceObj.title;
    
    myBadge++;
//    notification.applicationIconBadgeNumber = myBadge;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
//    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"1111" forKey:@"key"];
    NSDictionary *userDict = @{@"title":webServiceObj.title,@"content":webServiceObj.content};
    notification.userInfo = userDict;
    
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
        notification.repeatInterval = NSCalendarUnitDay;
    } else {
        // 通知重复提示的单位，可以是天、周、月
        notification.repeatInterval = NSDayCalendarUnit;
    }
    
    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    DLog(@"%@",userInfo);
}
// 本地通知回调函数，当应用程序在前台时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    DLog(@"noti:%@",notification);
    
    // 这里真实需要处理交互的地方
    // 获取通知所带的数据timer = [NSTimer scheduledTimerWithTimeInterval:webServiceObj.get_period/1000.0 target:self selector:@selector(startWebservice) userInfo:nil repeats:YES];
    NSString *titleStr = [notification.userInfo objectForKey:@"title"];
    NSString *contentStr = [notification.userInfo objectForKey:@"content"];
//    NSString *messageStr = [notification.userInfo objectForKey:@"key"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr
                                                    message:contentStr
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定",nil];
    [alert show];
    
    // 更新显示的徽章个数
//    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
//    int badgeI = [[NSString stringWithFormat:@"%ld",badge] intValue];
//    badgeI--;
//    badgeI = badgeI >= 0 ? badgeI : 0;
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 在不需要再推送时，可以取消推送
    [self cancelLocalNotificationWithKey:@"title"];
}
- (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        DLog(@"%@",notification.userInfo);
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
//                break;  
            }
        }  
    }  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
    }else {
        NSDictionary *myDictionary = [NSDictionary dictionaryWithObject:webServiceObj.url forKey:@"url"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationUrl" object:myDictionary];
    }
}

-(NSDate *)dateWithString:(NSString *)string{//时间字符串转时间
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式,这里可以设置成自己需要的格式
    NSDate *date =[dateFormat dateFromString:string];
    return date;
}
@end
