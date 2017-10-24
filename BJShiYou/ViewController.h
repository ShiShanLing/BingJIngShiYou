//
//  ViewController.h
//  BJShiYou
//
//  Created by vstyle on 15/11/9.
//  Copyright (c) 2015年 com.vstyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
//10月24下午6点54更新
@protocol JavaScriptObjectExport <JSExport>
- (void)log:(NSString*)string;
#pragma mark - 数据操作
- (void)app_close; // 应用关闭
- (void)web_go_back; // 返回上一页
- (void)db_insert:(NSString *)name :(NSString *)value; // 插入数据

- (void)db_delete:(NSString *)name; // 删除数据

- (void)db_update:(NSString *)name :(NSString *)value; // 更新数据
- (NSString *)db_select_all; // 查询所有数据

- (NSString *)db_select_value_string:(NSString *)name; // 查询某一条数据 -->返回json格式

- (NSString *) db_select_value_single:(NSString *)name; // 查询某一条消息，返回字符串，返回值为value的值（非JSON，纯结果）
#pragma mark - 用户
- (NSString *)test_obtain_local_data:(NSString *)name;

//- (NSString *)test_obtain_local_data:(NSString *)name;
- (void)saveUser:(NSString *)name :(NSString *)password; // 保存用户

- (void)clearUser; // 清除用户
 // 获取最新的已保存的用户，返回JSON格式（id，name-用户名，value-密码，time）
- (NSString *)getUser;
//JSExportAs(<#PropertyName#>, <#Selector#>)
- (void)setExtparam:(NSString *)extpatam; // 用户身份
- (void)deleteExtparam; //删除用户身份
- (NSString *)getExtparam; //获取用户身份
#pragma mark - 通知和callback
- (void)set_notify_open; // 通知打开
- (void)set_notify_close; // 通知关闭
- (NSString *)get_notify_state; // 获取通知状态
- (void)set_can_callback; // 设置可以回调
- (void)set_no_callback; // 设置不可以回调
#pragma mark - Wbeservice
- (void)setWebServiceURL:(NSString *)serviceURL;
- (void)deleteWebServiceURL;
- (NSString *)getWebServiceURL;
- (NSString *)get_app_version; // 获取应用版本号
/**
 *获取图片
 */
- (void)choosePhoneImage:(NSString *)functionName; //获取图片
/**
 *请求定位
 */
JSExportAs(getAdressInfo, - (void)getAdressInfo:(NSString *)functionName);
/**
 *二维码扫描
 */
JSExportAs(codeScan, - (void)codeScan:(NSString *)functionName);
/**
 *上传图片和地理位置
 */
JSExportAs(choosePhoneImageWithAddress, - (void)choosePhoneImageWithAddress:(NSString *)funtionName);
/**
 *测试保存
 */

JSExportAs(db_insert, -(void)db_insert:(NSString *)name password:(NSString *)password);
//JSExportAs(db_select_value_single, -(NSString *)db_select_value_single:(NSString *)userData);

- (NSString *)getTailoringCompressImageBase64:(NSString *)path :(BOOL)isNeedTailoring :(double)percentageStartX :(double)percentageStartY :(double)percentageWidth :(double)percentageHeight; //对图片进行裁剪

@end

@interface ViewController : UIViewController<JavaScriptObjectExport>

@property (strong, nonatomic) IBOutlet UIWebView *myWebView;
@property (strong, nonatomic) NSString *openUrlStr;
@property (assign,nonatomic) BOOL imageIsSave;
@property (strong, nonatomic) NSString *theNextPageUrlStr;
@property (strong,nonatomic) NSString *callbcakFunctionName;
@property (strong, nonatomic)NSString *locationStr;

@end
