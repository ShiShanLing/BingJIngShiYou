//
//  ScanViewController.m
//  QRCodeDemo
//
//  Created by huanxin xiong on 2016/12/5.
//  Copyright © 2016年 xiaolu zhao. All rights reserved.
//

#import "ScanViewController.h"
// 二维码需要的框架
#import <AVFoundation/AVFoundation.h>
#import "MaskView.h"
#define  kScreen_heigth [UIScreen mainScreen].bounds.size.height//屏幕高度
#define  kScreen_widht  [UIScreen mainScreen].bounds.size.width//屏幕高度
@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

// 创建AVCaptureSession
@property (nonatomic, strong) AVCaptureSession *session;
// 闪光灯是否打开
@property (nonatomic, assign) BOOL flashOpen;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *returnimage = [UIImage imageNamed:@"return_black"];
    //设置图像渲染方式
    returnimage = [returnimage imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithImage:returnimage style:UIBarButtonItemStylePlain target:self action:@selector(handleReturn)];//自定义导航条按钮
    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
    
    UIImage *lightImage = [UIImage imageNamed:@"openLight"];//

    lightImage = [lightImage imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];

    UIBarButtonItem *lightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:lightImage style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];//自定义导航条按钮
    self.navigationItem.rightBarButtonItem = lightBarButtonItem;

    MaskView *maskView = [[MaskView alloc] initWithFrame:CGRectMake(0, 0, kScreen_widht, kScreen_heigth)];
    maskView.alpha = 0.7;
    [self.view addSubview:maskView];
    
    //利用session生成一个AVCaptureVideoPreviewLayer加到view的layer上，就可以实时显示摄像头捕捉的内容了
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];

}
//返回上一界面
- (void)handleReturn {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [super.navigationController setNavigationBarHidden:NO];
    //开始捕获
      dispatch_async(dispatch_get_main_queue(), ^{
          [self.session startRunning];
      });
}

- (void)viewWillDisappear:(BOOL)animated {
    //停止捕获
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}
#pragma makr - AVCaptureMetadataOutputObjectsDelegate
//扫描出结果后调用该代理方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        NSLog(@"metadataObject.stringValue%@", metadataObject.stringValue);
           if (self.flashOpen){
               AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
               device.torchMode = AVCaptureTorchModeOn;
               device.flashMode = AVCaptureFlashModeOn;
           }
        if ([_delegate respondsToSelector:@selector(ScanResultsText:)]) {
            [_delegate ScanResultsText:metadataObject.stringValue];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}
#pragma mark - Getter
- (AVCaptureSession *)session {
    if (!_session) {
        _session = ({
            //获取摄像设备
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            //创建输入流
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            if (!input)
            {
                return nil;
            }
            //创建输出流
            AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
            //设置代理 在主线程里刷新
            [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            //设置扫描区域的比例
            CGFloat width = 300 / CGRectGetHeight(self.view.frame);
            CGFloat height = 300 / CGRectGetWidth(self.view.frame);
            output.rectOfInterest = CGRectMake((1 - width) / 2, (1- height) / 2, width, height);
            
            AVCaptureSession *session = [[AVCaptureSession alloc] init];
            //高质量采集率
            [session setSessionPreset:AVCaptureSessionPresetHigh];
            [session addInput:input];
            [session addOutput:output];
            
            //设置扫码支持的编码格式(这里设置条形码和二维码兼容)
            output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                           AVMetadataObjectTypeEAN13Code,
                                           AVMetadataObjectTypeEAN8Code,
                                           AVMetadataObjectTypeCode128Code];
            
            session;
        });
    }
    return  _session;
}
#pragma mark - Action
- (void)rightBarButtonAction:(UIBarButtonItem *)item
{
    self.flashOpen = !self.flashOpen;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        if (self.flashOpen){
            UIImage *lightImage = [UIImage imageNamed:@"closeLight"];//
            lightImage = [lightImage imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:lightImage style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
            
            device.torchMode = AVCaptureTorchModeOn;
            device.flashMode = AVCaptureFlashModeOn;
        }else{
            UIImage *lightImage = [UIImage imageNamed:@"openLight"];//
            lightImage = [lightImage imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:lightImage style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
            
            device.torchMode = AVCaptureTorchModeOff;
            device.flashMode = AVCaptureFlashModeOff;
        }
        
        [device unlockForConfiguration];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
