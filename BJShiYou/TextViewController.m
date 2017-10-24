//
//  TextViewController.m
//  JYOnLine
//
//  Created by 石山岭 on 2017/8/9.
//  Copyright © 2017年 com.vstyle. All rights reserved.
//

#import "TextViewController.h"
#import "DatabaseOperations.h"
#import "NSObject+BJShiYou.h"
#import "ZYQAssetPickerController.h"
#import "Header.h"
#import <AssetsLibrary/AssetsLibrary.h>  // 必须导入
#import "QBImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSObject+BJShiYou.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <objc/runtime.h>
#import "AFNetworking.h"
#import "DPImagePickerVC.h"
#import "PhotoEditorsVC.h"
#import <CoreLocation/CoreLocation.h>
#import "MyPosition.h"
#define  kScreen_heigth [UIScreen mainScreen].bounds.size.height//屏幕高度
#define  kScreen_widht  [UIScreen mainScreen].bounds.size.width//屏幕高度
@interface TextViewController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBImagePickerControllerDelegate, DPImagePickerDelegate, PhotoEditorsVCDelegate, CLLocationManagerDelegate,UIGestureRecognizerDelegate>

//存储用户消息推送习惯的数组
@property (nonatomic, strong)NSMutableArray *messageArray;

@property (nonatomic, strong)UIImagePickerController *picker;//拍照

@property (nonatomic, strong)UIImage *ReplaceUserImage;

/**
 *
 */
@property (nonatomic, strong) UIImageView * showImageView;
@property (nonatomic,strong) CLLocationManager *manager;
//位置编码
@property (nonatomic, strong)CLGeocoder *geocoder;
@end

@implementation TextViewController{
    NSMutableArray *imageArray;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.delegate = self;
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    self.navigationController.navigationBarHidden = NO;
    
   }

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.manager.delegate = nil;
    
}
- (void)handleBtn1 {
    
    self.showImageView.image = self.ReplaceUserImage;
}
- (void)getAdressInfo {
    // 实例化对象
    self.manager = [[CLLocationManager alloc] init];
    
    _manager.delegate = self;
    
    // 请求授权，记得修改的infoplist，NSLocationAlwaysUsageDescription（描述）
    [_manager requestAlwaysAuthorization];
   
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
    }
}
#pragma mark - 代理方法，当授权改变时调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
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
    //输出方向
    //地理方向
//    NSLog(@"true = %f ",newHeading.trueHeading);
//    // 磁极方向
//    NSLog(@"mag = %f",newHeading.magneticHeading);
}

#pragma mark - 定位代理
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%@",locations);
    //获取当前位置
    CLLocation *location = manager.location;
    //获取坐标
    CLLocationCoordinate2D corrdinate = location.coordinate;
    
    
    CLLocation *Clocation=[locations firstObject];
    CLLocationCoordinate2D coordinate=Clocation.coordinate;
    NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed);
    
    [self.geocoder reverseGeocodeLocation:Clocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark=[placemarks firstObject];
        NSArray *addrArray =placemark.addressDictionary[@"FormattedAddressLines"];
        [MyPosition mainSingleton].address = addrArray[0];
        //State-City-
        NSLog(@"详细信息:%@",addrArray[0]);
    }];
    //打印地址
    NSLog(@"latitude = %f longtude = %f",corrdinate.latitude,corrdinate.longitude);
    //停止定位
    [_manager stopUpdatingLocation];
}

- (void)handleBtn {
    
    
    if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
        
        // 请求授权，记得修改的infoplist，NSLocationAlwaysUsageDescription（描述）
        [_manager requestAlwaysAuthorization];
    } else{
        //用户拒绝开启用户权限
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"打开[定位服务权限]来允许[中石油]确定您的位置" message:@"请在系统设置中开启定位服务(设置>隐私>定位服务>开启)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        alertView.delegate=self;
        alertView.tag=3;
        [alertView show];
        
    }
    
    __weak TextViewController *VC = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertV = [UIAlertController alertControllerWithTitle:@"提醒!" message:@"获取照片" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        UIAlertAction *TakingPicturesCancle = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [VC throughCameraObtainImage];
        }];
        UIAlertAction *PhotoAlbumConfirm = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            VC.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:_picker animated:YES completion:nil];
            
        }];
        // 3.将“取消”和“确定”按钮加入到弹框控制器中
        [alertV addAction:cancle];
        [alertV addAction:TakingPicturesCancle];
        [alertV addAction:PhotoAlbumConfirm];
        // 4.控制器 展示弹框控件，完成时不做操作
        [self presentViewController:alertV animated:YES completion:^{
            nil;
        }];

    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    PhotoEditorsVC *VC = [[PhotoEditorsVC alloc] initWithNibName:@"PhotoEditorsVC" bundle:nil];
    VC.delegate = self;
    VC.showImage = image;
    [self.navigationController pushViewController:VC animated:YES];
    NSLog(@"选择完毕----image:%@-----info:%@",image,editingInfo);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.geocoder = [[CLGeocoder alloc]init];
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    btn.frame = CGRectMake(100, 100, 100, 100);
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitle:@"你好啊" forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(handleBtn) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn];
    
    self.showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 100, 100, 100)];
    _showImageView.backgroundColor = [UIColor greenColor];
    _showImageView.contentMode = UIViewContentModeScaleAspectFit;
    _showImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tap.numberOfTouchesRequired = 1; //手指数
    tap.numberOfTapsRequired = 1; //tap次数
    tap.delegate= self;
    [_showImageView addGestureRecognizer:tap];
    [self.view addSubview:_showImageView];
    
    UIButton *btn1 = [UIButton buttonWithType:(UIButtonTypeSystem)];
    btn1.frame = CGRectMake(100, 250, 100, 100);
    btn1.backgroundColor = [UIColor grayColor];
    [btn1 setTitle:@"刷新图片" forState:(UIControlStateNormal)];
    [btn1 addTarget:self action:@selector(handleBtn1) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn1];

    
    self.view.backgroundColor = [UIColor redColor];
}

- (void)handleTap {
    static int a = 1;
    if (a %2 ==0) {
        a++;
        _showImageView.frame = CGRectMake(250, 100, 100, 100);
    }else {
        a++;
        _showImageView.frame = CGRectMake(0, 64, kScreen_widht, kScreen_heigth-64);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

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
    NSLog(@"sourceImage%@",sourceImage);
    PhotoEditorsVC *VC = [[PhotoEditorsVC alloc] initWithNibName:@"PhotoEditorsVC" bundle:nil];
    VC.delegate = self;
    VC.showImage = sourceImage;
    [self.navigationController pushViewController:VC animated:YES];
}
//用相册获取头像
- (void)getCutImage:(UIImage *)image{
    self.showImageView.image = image;

    PhotoEditorsVC *VC = [[PhotoEditorsVC alloc] initWithNibName:@"PhotoEditorsVC" bundle:nil];
    VC.delegate = self;
    VC.showImage = image;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)dataTransfer:(UIImage *)image{
    
    NSLog(@"dataTransfer%@", image);
    
    
    
    NSString *path_document = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_document stringByAppendingString:@"/Documents/pic.png"];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    
    UIImage *getimage2 = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@"image2 is size %@",NSStringFromCGSize(getimage2.size));
    
    self.ReplaceUserImage = image;
    self.showImageView.image = image;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
