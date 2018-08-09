//
//  ViewController.m
//  BJShiYou
//
//  Created by vstyle on 15/11/9.
//  Copyright (c) 2015年 com.vstyle. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "DatabaseOperations.h"
#import "WebViewJavascriptBridge.h"
#import <objc/runtime.h>
#import "NSObject+BJShiYou.h"
#import "Header.h"
#import "WellcomeVC.h"
#import "TextViewController.h"
#import "ZYQAssetPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>  // 必须导入
#import "QBImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import "ScanViewController.h"
#import "PhotoEditorsVC.h"
#import "DPImagePickerVC.h"
#import "MyPosition.h"
// 照片原图路径
#define KOriginalPhotoImagePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OriginalPhotoImages"]

// 视频URL路径
#define KVideoUrlPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"VideoURL"]
// caches路径
#define KCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

static int returnNum;
//是否允许发送地理位置  默认否
static BOOL  positioning;
//上传图片的时候是否要穿地理位置 因为他的新方法还有应用到项目中 所以用这个方法来判断 如果他调用的新方法那么就上传
static BOOL  uploadLocation;
@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate,UIWebViewDelegate,JavaScriptObjectExport,QBImagePickerControllerDelegate,DPImagePickerDelegate,ScanViewControllerDelegate,PhotoEditorsVCDelegate> {
    UIView *statusBarBgView;
    NSMutableArray *imageArray;
}
@property (nonatomic, strong)UIImagePickerController *picker;//拍照

@property (nonatomic, strong)UIImage *ReplaceUserImage;
/**
 *
 */
@property (nonatomic, strong) JSContext *context;
//定位
@property (nonatomic,strong) CLLocationManager *manager;
//位置编码
@property (nonatomic, strong)CLGeocoder *geocoder;
/**
 *
 */
@property (nonatomic, strong)ScanViewController *scanViewController;
@end

@implementation ViewController {
    
    NSString * EditImage;
    NSString *currentURL;
}

- (void)viewWillAppear:(BOOL)animated{
    //分支测试信息
    [super viewWillAppear:animated];
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    [_manager requestAlwaysAuthorization];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:1.0f];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifitionUrl:) name:@"NotificationUrl" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifitionUrl:) name:@"CLLocationManager" object:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    //    横屏是隐藏信号区背景View
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        statusBarBgView.hidden = YES;
    } else {
        statusBarBgView.hidden = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.manager.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationUrl" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CLLocationManager" object:nil];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self respondsToSelector:@selector(willAnimateFirstHalfOfRotationToInterfaceOrientation:duration:)];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self wellcome];
    positioning = NO;
    uploadLocation = NO;
    self.geocoder = [[CLGeocoder alloc]init];
    
    //判断定位是否开启
    if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
        // 实例化对象
        if (!_manager) {
            _manager = [[CLLocationManager alloc] init];
             self.manager.delegate = self;
        }
    } else{
        //用户拒绝开启用户权限
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"打开[定位服务权限]来允许[中石油]确定您的位置" message:@"请在系统设置中开启定位服务(设置>隐私>定位服务>开启)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        alertView.delegate=self;
        alertView.tag=2;
        [alertView show];
    }

    returnNum = 0;
    self.navigationController.navigationBarHidden = YES;
    if ([Is EmptyOrNullString:self.openUrlStr]) {
        self.openUrlStr = @"http://123.127.191.221:1000/";
        //        http://123.127.191.221:1000/ 生产地址
        //        http://msptest.zjmicon.com/ 测试地址
    }
    self.navigationController.navigationBar.alpha = 0.1;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.openUrlStr]];
    _myWebView = [[UIWebView alloc] init];
    _myWebView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-22);
    _myWebView.delegate = self;
    [_myWebView loadRequest:request];
    [self.view addSubview:_myWebView];
    //    创建信号去背景View
    statusBarBgView = [[UIView alloc] init];
    statusBarBgView.backgroundColor = [UIColor colorWithRed:189/255.0f green:189/255.0f blue:194/255.0f alpha:1.0f];
    statusBarBgView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
    [self.view addSubview:statusBarBgView];
    self.scanViewController = [[ScanViewController alloc] init];
    self.scanViewController.delegate = self;
}
#pragma mark — 欢迎页面
- (void)wellcome{
    NSInteger wellcomeVersion = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_WELLCOME_VERSION];
    if (wellcomeVersion < WELLCOME_VERSION) {
        WellcomeVC *wvc = [[WellcomeVC alloc] init];
        wvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:wvc animated:NO completion:nil];
    }
    //NSLog(@"网络状态--------%d",[Network getNetworkStatus]);
    if ([Network getNetworkStatus] == 1 || [Network getNetworkStatus] == 4){
        TextViewController *selectTheNetworkVC = [TextViewController new];
      // [self.navigationController pushViewController:selectTheNetworkVC animated:YES];
    }
}
#pragma mark - 接到打开新网页的通知
- (void)notifitionUrl:(NSNotification*) notification
{
    
    NSDictionary *urlDict = [notification object];//获取到传递的对象
    NSURL *url = [NSURL URLWithString:urlDict
                  [@"url"]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.myWebView loadRequest:urlRequest];
}

- (CGRect)frameForOrientation:(UIInterfaceOrientation)orientation {
    CGRect frame;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
        statusBarBgView.hidden = YES;
    } else {
        statusBarBgView.hidden = NO;
        frame = [UIScreen mainScreen].bounds;
    }
    return frame;
}
#pragma mark -UIWebViewDelegate


- (void)webViewDidStartLoad:(UIWebView *)webView{
        [SVProgressHUD show];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [SVProgressHUD dismiss];
}

//- (NSCachedURLResponse*)cachedResponseForRequest:(NSURLRequest*)request {
//
//
//
//}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad%@", webView.isLoading? @"YES":@"NO");

    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    self.context[@"ios"] = self;
    if (webView.isLoading) {
        return;
    }
    [SVProgressHUD dismiss];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
 //   NSLog(@"shouldStartLoadWithRequest%@", request);
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    self.context[@"ios"] = self;
    
    NSString *urlStr = request.URL.absoluteString;
    NSLog(@"urlStrQQ%@------self.openUrlStrQQ%@", request.URL.absoluteString, self.openUrlStr);
    self.theNextPageUrlStr = urlStr;
    
    if (![self.openUrlStr isEqualToString:request.URL.absoluteString] && ![self.openUrlStr isEqualToString:@"about:blank"]) {
        ViewController *vc = [ViewController new];
        vc.openUrlStr = nil;
        vc.openUrlStr = request.URL.absoluteString;
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}
#pragma mark - 返回上一页
- (void)webGoBack{
    {
    }
    
}
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (void)log:(NSString*)string {
    DLog(@"js: %@", string);
}
- (void)app_close{
    DLog(@"%@",@"程序关闭");
    exit(0);
}

- (void)web_go_back{
    dispatch_async(dispatch_get_main_queue(), ^{

        if ([self.myWebView canGoBack]) {
            [self.myWebView goBack];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }

    
    });
}

- (void)db_insert:(NSString *)name :(NSString *)value{
    
    DLog(@"\n插入数据名称---%@\n插入数据    ---%@",name,value);
    [DatabaseOperations deleteDataWithName:name];
    [DatabaseOperations insertDataWithName:name withValue:value];
}

-(void)db_delete:(NSString *)name{
    DLog(@"删除数据");
    [DatabaseOperations deleteDataWithName:name];
}

- (void)db_update:(NSString *)name :(NSString *)value{ // 更新数据
    DLog(@"更新数据");
    [DatabaseOperations updateDataWithName:name withValue:value];
}

- (NSString *)db_select_all{ //查询所有数据，返回JSON格式（id，name，value，time）
    DLog(@"查询所有数据，返回JSON格式（id，name，value，time）");
    NSArray *dataArr = [DatabaseOperations getAll];
    NSString *dataStr = dataArr.toJSON;
    return dataStr;
}

- (NSString *)db_select_value_string:(NSString *)name{ // 查询某一条数据 -->返回json格式
    DLog(@"查询某一条数据 -->返回json格式");
    NSDictionary *dataDict = [DatabaseOperations selectValueWhithName:name];
    NSString *dataStr = dataDict.toJSON;
    return dataStr;
}

- (NSString *) db_select_value_single:(NSString *)name{ // 查询某一条消息，返回字符串，返回值为value的值（非JSON，纯结果）
    DLog(@"查询某一条消息，返回字符串，返回值为value的值（非JSON，纯结果）");
    
    return [DatabaseOperations selectValueWhithSingleName:name];


}

- (void)saveUser:(NSString *)name :(NSString *)password{ // 保存用户
    DLog(@"保存用户");
    [DatabaseOperations clearUser];
    [DatabaseOperations saveUserWithUserName:name WithUserPassWord:password];
}

- (void)clearUser{ // 清除用户
    DLog(@"清除用户");
    [DatabaseOperations clearUser];
}

- (NSString *)getUser {// 获取最新的已保存的用户，返回JSON格式（id，name-用户名，value-密码，time）
    NSDictionary *dict = [DatabaseOperations getUser];
    DLog(@"获取最新的已保存的用户，返回JSON格式（id，name-用户名，value-密码，time）%@",dict);
    return dict.toJSON;
}

- (void)set_notify_open{
    DLog(@"通知打开");
    [DatabaseOperations setNotifyOpenWithVale:@"1"];
}

- (void)set_notify_close{
    DLog(@"通知关闭");
    [DatabaseOperations setNotifyCloseWithVale:@"0"];
}

- (NSString *)get_notify_state{
    DLog(@"获取通知状态");
    return [DatabaseOperations getNotifyState];
}

- (void)set_can_callback{
    DLog(@"设置可以callback");
    [[NSUserDefaults standardUserDefaults] setValue:@"TRUE" forKey:self.theNextPageUrlStr];
}

- (void)set_no_callback{
    DLog(@"设置不可以callback");
    [[NSUserDefaults standardUserDefaults] setValue:@"FALSE" forKey:self.theNextPageUrlStr];
}

- (void)setExtparam:(NSString *)extpatam{
    DLog(@"存储身份信息");
    [DatabaseOperations setExtparamWithString:extpatam];
}

- (void)deleteExtparam{
    DLog(@"删除身份信息");
    [DatabaseOperations deleteExtparam];
}

- (NSString *)getExtparam{
    DLog(@"获取身份信息");
    NSString *extparam = [DatabaseOperations getExtparam];
    return extparam;
}

- (void)setWebServiceURL:(NSString *)serviceURL{
    DLog(@"存储Webs的URL");
    [DatabaseOperations setWebServiceURL:serviceURL];
}

- (void)deleteWebServiceURL{
    DLog(@"删除Webs的URL");
    [DatabaseOperations deleteWebServiceURL];
}

- (NSString *)getWebServiceURL{
    DLog(@"获取Webs的URL");
    NSString *webServiceUrl = [DatabaseOperations getWebServiceURL];
    return webServiceUrl;
}

- (NSString *)get_app_version{
    DLog(@"获取软件版本号");
    NSString *bundleStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *returnBundleStr = [NSString stringWithFormat:@"ios_%@",bundleStr];
    return returnBundleStr;
}
//上传图片的时候上传地理位置
- (void)choosePhoneImageWithAddress:(NSString *)funtionName {
    self.callbcakFunctionName = funtionName;
    // 请求授权，记得修改的infoplist，NSLocationAlwaysUsageDescription（描述）
    [_manager requestAlwaysAuthorization];
    __weak ViewController *VC = self;
    // 更UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertV = [UIAlertController alertControllerWithTitle:@"提示!" message:@"中石油想要从您的手机获取照片" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        UIAlertAction *TakingPicturesCancle = [UIAlertAction actionWithTitle:@"拍照并编辑" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            EditImage = @"0";
            [self throughCameraObtainImage];
        }];
        UIAlertAction *PhotoYESAlbumConfirm = [UIAlertAction actionWithTitle:@"从相册选择并编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            EditImage = @"1";
            VC.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [VC presentViewController:_picker animated:YES completion:nil];
        }];
        UIAlertAction *PhotoNOAlbumConfirm = [UIAlertAction actionWithTitle:@"从相册选择不编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            EditImage = @"2";
            VC.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [VC presentViewController:_picker animated:YES completion:nil];
        }];
        // 3.将“取消”和“确定”按钮加入到弹框控制器中
        [alertV addAction:cancle];
        [alertV addAction:TakingPicturesCancle];
        [alertV addAction:PhotoYESAlbumConfirm];
        [alertV addAction:PhotoNOAlbumConfirm];
        // VC.控制器 展示弹框控件，完成时不做操作
        [VC presentViewController:alertV animated:YES completion:^{
            nil;
        }];
    });
}



#pragma mark - JS调用的获取图片的方法 --定位
- (void)choosePhoneImage:(NSString *)functionName{
    __weak ViewController *VC = self;
    
    if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
            
            // 请求授权，记得修改的infoplist，NSLocationAlwaysUsageDescription（描述）
            [_manager requestAlwaysAuthorization];
    } else{
        //用户拒绝开启用户权限
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"打开[定位服务权限]来允许[中石油]确定您的位置" message:@"请在系统设置中开启定位服务(设置>隐私>定位服务>开启)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
            alertView.delegate=self;
            alertView.tag=3;
            [alertView show];
        });
    }
    //NSLog(@"functionName%@", functionName);
    self.callbcakFunctionName = functionName;
    // 更UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertV = [UIAlertController alertControllerWithTitle:@"提示!" message:@"中石油想要从您的手机获取照片" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        UIAlertAction *TakingPicturesCancle = [UIAlertAction actionWithTitle:@"拍照并编辑" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            EditImage = @"0";
            [self throughCameraObtainImage];
        }];
        UIAlertAction *PhotoYESAlbumConfirm = [UIAlertAction actionWithTitle:@"从相册选择并编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            EditImage = @"1";
            VC.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [VC presentViewController:_picker animated:YES completion:nil];
        }];
        UIAlertAction *PhotoNOAlbumConfirm = [UIAlertAction actionWithTitle:@"从相册选择不编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            EditImage = @"2";
            VC.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [VC presentViewController:_picker animated:YES completion:nil];
        }];
        
        // 3.将“取消”和“确定”按钮加入到弹框控制器中
        [alertV addAction:cancle];
        [alertV addAction:TakingPicturesCancle];
        [alertV addAction:PhotoYESAlbumConfirm];
        [alertV addAction:PhotoNOAlbumConfirm];
        // 4.控制器 展示弹框控件，完成时不做操作
        [self presentViewController:alertV animated:YES completion:^{
            nil;
        }];
    });
    
}

//用相机获取头像
-(void)throughCameraObtainImage{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:self.picker animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"failed to camera"
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *sourceImage = info[UIImagePickerControllerOriginalImage];
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    self.ReplaceUserImage = sourceImage;
    //NSLog(@"sourceImage%@",sourceImage);
    if ([EditImage isEqualToString:@"2"]) {
        [self imageWithUrl:nil withFileName:@"tempFile" withImage:sourceImage];
        
    }else {
        PhotoEditorsVC *VC = [[PhotoEditorsVC alloc] initWithNibName:@"PhotoEditorsVC" bundle:nil];
        VC.delegate = self;
        VC.NeedAddress = EditImage;
        VC.showImage = sourceImage;
        [self.navigationController pushViewController:VC animated:YES];
        
    }
}


////用相册获取头像 有问题暂时不用
//- (void)getCutImage:(UIImage *)image{
//
//    if (EditImage) {
//        PhotoEditorsVC *VC = [[PhotoEditorsVC alloc] initWithNibName:@"PhotoEditorsVC" bundle:nil];
//        VC.delegate = self;
//        VC.NeedAddress = @"0";
//        VC.showImage = image;
//        [self.navigationController pushViewController:VC animated:YES];
//    }else {
//        [self.navigationController popViewControllerAnimated:YES];
//        [self imageWithUrl:nil withFileName:@"tempFile" withImage:image];
//    }
//}

- (void)dataTransfer:(UIImage *)image{
    
    [self imageWithUrl:nil withFileName:@"tempFile" withImage:image];
}

#pragma mark - ZYQAssetPickerControllerDelegate
// 将原始图片的URL转化为NSData数据,写入沙盒

- (void)imageWithUrl:(NSURL *)url withFileName:(NSString *)fileName withImage:(UIImage *)image {
    //NSLog(@"imageWithUrl1%@", url);
    // 进这个方法的时候也应该加判断,如果已经转化了的就不要调用这个方法了
    // 如何判断已经转化了,通过是否存在文件路径
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KOriginalPhotoImagePath]) {
        [fileManager createDirectoryAtPath:KOriginalPhotoImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([Is EmptyOrNullString:url]) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        NSString * imagePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:fileName];
        [imageData writeToFile:imagePath atomically:YES];
       
            [self.myWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');",self.callbcakFunctionName,imagePath]];
        
    }else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (url) {
                //NSLog(@"imageWithUrl2%@", url);
                // 主要方法
                [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                    
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    
                    Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                    
                    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                    
                    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                    NSString * imagePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:fileName];
                    [data writeToFile:imagePath atomically:YES];
                    // 更UI
                    NSData *data1 = [NSData dataWithContentsOfURL:[NSURL  URLWithString:imagePath]];
                    UIImage *image = [UIImage imageWithData:data1]; // 取得图片
                    //NSLog(@"dataWithContentsOfURL%@", image);
                    
                    self.imageIsSave = YES;
                   // NSLog(@"imagePath%@  url%@ self.locationStr%@", imagePath, url, self.locationStr);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 更UI
                        // 这里的代码会在主线程执行
                      
                            [self.myWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');",self.callbcakFunctionName,imagePath]];
                        
                    });
                } failureBlock:nil];
            }
        });
    }
}

- (NSString *)getTailoringCompressImageBase64:(NSString *)path :(BOOL)isNeedTailoring :(double)percentageStartX :(double)percentageStartY :(double)percentageWidth :(double)percentageHeight {
  //  DLog(@"path=%@-------isNeedTailoring=%d-------percentageStartX=%f-------percentageStartY=%f-------percentageWidth=%f-------percentageHeight=%f",path,isNeedTailoring,percentageStartX,percentageStartY,percentageWidth,percentageHeight);
    
    if (isNeedTailoring) {
        //        NSLog(@"%@",path);
        UIImage *appleImage = [[UIImage alloc] initWithContentsOfFile:path];
        CGSize dimension = appleImage.size;
        CGRect rect = CGRectMake(dimension.width *percentageStartX, dimension.height *percentageStartY, dimension.width *percentageWidth, dimension.height *percentageHeight);
        UIImage *finalImage = [self getPartOfImage:[self fixOrientation:appleImage] rect:rect];
        NSData *finalData = UIImageJPEGRepresentation(finalImage, 1.0);
        NSString *base64Str = [self base64EncodedStringFrom:finalData];
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:nil];
        //        NSLog(@"%@ -- %@ -- %@ -- %lu -- \n\n\n%@",path,appleImage,finalImage,(unsigned long)finalData.length,base64Str);
        return base64Str;
    }else {
        UIImage *appleImage = [[UIImage alloc] initWithContentsOfFile:path];
        NSData *finalData = UIImageJPEGRepresentation([self fixOrientation:appleImage], 0.1);
        NSString *base64Str = [self base64EncodedStringFrom:finalData];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:nil];
        return base64Str;
    }
    return nil;
}

- (UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset {
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    CGImageRef imgRef = [assetRep fullResolutionImage];
    UIImage *img = [UIImage imageWithCGImage:imgRef
                                       scale:assetRep.scale
                                 orientation:(UIImageOrientation)assetRep.orientation];
    return img;
}
//图片方向纠正
- (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
//截取一张完整的图片 img：截取的对象 partRect：截取的大小
- (UIImage *)getPartOfImage:(UIImage *)img rect:(CGRect)partRect {
    CGImageRef imageRef = img.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, partRect);
    UIImage *retImg = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    return retImg;
}
//base64加密
- (NSString *)base64EncodedStringFrom:(NSData *)data {
    if ([data length] == 0)
        return @"";
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

- (void)getAdressInfo:(NSString *)functionName{
    //NSLog(@"functionName%@", functionName);
    
    if (self.locationStr.length > 0) {
                // 这里的代码会在主线程执行
                [self.myWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showAdress('%@');",self.locationStr]];
    }
    // 请求授权，记得修改的infoplist，NSLocationAlwaysUsageDescription（描述）
    [_manager requestAlwaysAuthorization];
}
#pragma mark -定位的 代理方法，当授权改变时调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    // 获取授权后，通过
    //判断定位是否开启
    if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied))
    {
        //开始定位(具体位置要通过代理获得)
        [_manager startUpdatingLocation];
        //设置精确度
        _manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        //设置过滤距离
        _manager.distanceFilter = 1000;
        //开始定位方向
        [_manager startUpdatingHeading];
        
    } else{
        
        //用户拒绝开启用户权限
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"打开[定位服务权限]来允许[中石油]确定您的位置" message:@"请在系统设置中开启定位服务(设置>隐私>定位服务>开启)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        alertView.delegate=self;
        alertView.tag=2;
        [alertView show];
        
    }
    
}
#pragma mark - 方向
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //    //输出方向
    //    //地理方向
    //    NSLog(@"true = %f ",newHeading.trueHeading);
    //    // 磁极方向
    //    NSLog(@"mag = %f",newHeading.magneticHeading);
}

#pragma mark - 定位代理

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //NSLog(@"%@",locations);
    //获取当前位置
    CLLocation *location = manager.location;
    //获取坐标
    CLLocationCoordinate2D corrdinate = location.coordinate;
    
    CLLocation *Clocation=[locations firstObject];
    CLLocationCoordinate2D coordinate=Clocation.coordinate;
  //  NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed);
    
    [self.geocoder reverseGeocodeLocation:Clocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark=[placemarks firstObject];
        NSArray *addrArray =placemark.addressDictionary[@"FormattedAddressLines"];
        [MyPosition mainSingleton].address = addrArray[0];
        //State-City-
   //     NSLog(@"详细信息:%@ [MyPosition mainSingleton].address%@",addrArray[0], [MyPosition mainSingleton].address);
        //打印地址
        NSMutableDictionary *URL_DIC = [NSMutableDictionary dictionary];
        URL_DIC[@"longtude"] = [NSString stringWithFormat:@"%f", corrdinate.longitude];
        URL_DIC[@"latitude"] = [NSString stringWithFormat:@"%f", corrdinate.latitude];
        URL_DIC[@"address"] = [MyPosition mainSingleton].address;
        NSError *parseError = nil;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:URL_DIC options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *strDic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        strDic =    [strDic  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        strDic = [strDic stringByReplacingOccurrencesOfString:@" " withString:@""];
        strDic = [strDic stringByReplacingOccurrencesOfString:@"\n" withString:@""];
   //     NSLog(@"latitude = %f longtude = %f strDic%@",corrdinate.latitude,corrdinate.longitude, strDic);
        self.locationStr = strDic;
    }];
    
    [MyPosition mainSingleton].latitude = [NSString stringWithFormat:@"%f", corrdinate.latitude];
    [MyPosition mainSingleton].longitude = [NSString stringWithFormat:@"%f", corrdinate.longitude];
  
    
//    self.locationStr = strDic;
//    if (positioning) {
//        // 这里的代码会在主线程执行
//        [self.myWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showAdress('%@');",strDic]];
//        positioning = NO;
//    }
    
    //停止定位
    _manager.delegate = nil;
    [_manager stopUpdatingLocation];
}
- (void)ScanResultsText:(NSString *)URL {
    self.callbcakFunctionName = [NSString stringWithFormat:@"%@('%@');",self.callbcakFunctionName,URL];
    [self.myWebView stringByEvaluatingJavaScriptFromString:self.callbcakFunctionName];
}
#pragma mark JS调用二维码扫描接口
- (void)codeScan:(NSString *)functionName {
    self.callbcakFunctionName = functionName;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.navigationController pushViewController:self.scanViewController animated:YES];
  });
}
//上传二维码扫描出来的结果
- (void)callback{
    [self.myWebView stringByEvaluatingJavaScriptFromString:self.callbcakFunctionName];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.000000) {
                //跳转到定位权限页面
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }else {
                //跳转到定位开关界面
                NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
                if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            //跳转到定位权限页面
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }else if (alertView.tag == 3) {
        if (buttonIndex == 1) {
            //跳转到定位权限页面
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }else {
        
    }
}

-(void)db_insert:(NSString *)name password:(NSString *)password {
    
    DLog(@"保存用户");
    [DatabaseOperations clearUser];
    [DatabaseOperations saveUserWithUserName:name WithUserPassWord:password];
}

- (NSString *) test_obtain_local_data:(NSString *)name {
    
        NSDictionary *dict = [DatabaseOperations getUser];
        DLog(@"获取最新的已保存的用户，返回JSON格式（id，name-用户名，value-密码，time）%@",dict);
        return dict.toJSON;
    
}

@end





