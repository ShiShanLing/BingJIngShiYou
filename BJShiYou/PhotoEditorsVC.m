//
//  PhotoEditorsVC.m
//  JYOnLine
//
//  Created by 石山岭 on 2017/8/9.
//  Copyright © 2017年 com.vstyle. All rights reserved.
//

#import "PhotoEditorsVC.h"
#import "LXFDrawBoard.h"
#import "LXFPrototypeBrush.h"
#import "LXFEraserBrush.h"
#import "TextViewController.h"
#import "UIView+SDAutoLayout.h"
#import "ViewController.h"
#import "painter.h"
#import "MyPosition.h"
#define  kScreen_heigth [UIScreen mainScreen].bounds.size.height//屏幕高度
#define  kScreen_widht  [UIScreen mainScreen].bounds.size.width//屏幕高度
#define kIphone6Height 667.0
#define kIphone6Width 375.0
#define kFit(x)  (kScreen_widht*((x)/kIphone6Width))
@interface PhotoEditorsVC ()<LXFDrawBoardDelegate>
@property (weak, nonatomic) IBOutlet LXFDrawBoard *drawNoard;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;
@property (weak, nonatomic) IBOutlet UIView *addrView;
/*** 描述 */
@property(nonatomic, copy) NSString *desc;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
//显示线条的颜色粗细
@property (weak, nonatomic) IBOutlet UILabel *lineThicknessColor;
@property (weak, nonatomic) IBOutlet UISlider *progressBar;
/**
 *
 */
@property (nonatomic, strong)NSMutableArray * colorAray;

@property (nonatomic ,weak) painter* colorPaint;
@end

@implementation PhotoEditorsVC
- (NSMutableArray *)colorAray {
    if (!_colorAray) {
        _colorAray = [NSMutableArray array];
    }
    return _colorAray;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.drawNoard.brush = [LXFPencilBrush new];
    self.drawNoard.lineColor = [UIColor redColor];
    self.drawNoard.lineWidth = 2.5;
     CGFloat Y = 3;
    NSArray *array  =@[[UIColor redColor],[UIColor greenColor],[UIColor blueColor],[UIColor cyanColor],[UIColor yellowColor],[UIColor magentaColor],[UIColor orangeColor],[UIColor purpleColor],[UIColor brownColor]];
    self.colorAray = [NSMutableArray arrayWithArray:array];
    for (int i = 0; i<self.colorAray.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeSystem)];
        btn.tag = 100 + i;
        btn.backgroundColor = self.colorAray[i];
        btn.frame = CGRectMake(Y, 0, 36, 36);
        [btn addTarget:self action:@selector(handleChangeColor:) forControlEvents:(UIControlEventTouchUpInside)];
        Y += 41;
        [self.mainScrollView addSubview:btn];
    }
    self.mainScrollView.contentSize = CGSizeMake(Y, 36);
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
   
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.colorAray removeAllObjects];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    __weak PhotoEditorsVC *VC = self;
    self.drawNoard.InterfaceClick = ^(NSString *test) {
        [VC ClosePalette];
    };
    self.drawNoard.image = self.showImage;
    [self.drawNoard setaddImage:self.showImage];
    self.drawNoard.delegate = self;
    self.drawNoard.brush = [LXFPencilBrush new];
    self.drawNoard.brush.lineColor = [UIColor redColor];
    self.drawNoard.brush.lineWidth = 2.5;
    self.lineThicknessColor.text =@"铅笔";
   
    painter *paint = [painter new];
    
    paint.frame = CGRectMake((kScreen_widht-200)/2, -200, 200, 200);
    //paint.center = CGPointMake((kScreen_widht-200)/2, 0.5 * paint.bounds.size.height + 64 );
    [self.view addSubview:paint];
    _colorPaint = paint;
    paint.colBlock = ^(UIColor *col){
        _drawNoard.lineColor= col;
        self.lineThicknessColor.backgroundColor = col;
    };
    
    NSLog(@"self.NeedAddress%@", self.NeedAddress);
    if (![self.NeedAddress isEqualToString:@"0"]) {
        self.addrLabel.hidden = YES;
        self.addrView.hidden = YES;
    }else {
        if ([MyPosition mainSingleton].address.length == 0) {
            self.addrLabel.hidden = YES;
            self.addrView.hidden = YES;
        }else {
            self.addrLabel.hidden = NO;
            self.addrView.hidden = NO;
            self.addrLabel.text = [MyPosition mainSingleton].address;
        }
    }
   
}
//编辑颜色

- (void)handleChangeColor:(UIButton *)sender {
    self.lineThicknessColor.backgroundColor = self.colorAray[sender.tag-100];
    self.drawNoard.lineColor = self.colorAray[sender.tag-100];
    [self ClosePalette];
}

- (void)RegisteredAccount {
    
   
}
- (IBAction)linekuandu:(UISlider *)sender {
    ///NSLog(@"linekuandu%.2f", sender.value/2);
    self.drawNoard.lineWidth = sender.value/2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)chexiao:(id)sender {
    [self ClosePalette];

    [self.drawNoard revoke];
}

- (IBAction)fanchexiao:(id)sender {
    [self ClosePalette];

    [self.drawNoard redo];
    
    
}

- (IBAction)qianbi:(id)sender {
     self.drawNoard.brush = [LXFPencilBrush new];
    self.lineThicknessColor.text =@"铅笔";
    [self ClosePalette];
}

- (IBAction)jiantou:(id)sender {
    self.drawNoard.brush = [LXFArrowBrush new];
    self.lineThicknessColor.text =@"箭头";
    [self ClosePalette];
}

- (IBAction)zhixian:(id)sender {
    self.drawNoard.brush = [LXFLineBrush new];
    self.lineThicknessColor.text =@"直线";
    [self ClosePalette];
}

- (IBAction)wenben:(id)sender {
     self.drawNoard.brush = [LXFTextBrush new];
    self.lineThicknessColor.text =@"文本";
    [self alterDrawBoardDescLabel];
    [self ClosePalette];
}


- (IBAction)jvxing:(id)sender {
    self.drawNoard.brush = [LXFRectangleBrush new];
    self.lineThicknessColor.text =@"矩形";
    [self ClosePalette];
}


- (IBAction)yuanxing:(id)sender {
    self.drawNoard.brush = [LXFPrototypeBrush new];
    self.lineThicknessColor.text =@"圆形";
    [self ClosePalette];
}

- (IBAction)hongse:(id)sender {
    self.drawNoard.lineColor = [UIColor redColor];
    [self ClosePalette];
}

- (IBAction)huangse:(id)sender {
    self.drawNoard.lineColor = [UIColor yellowColor];
    [self ClosePalette];
}


- (IBAction)lanse:(id)sender {
    self.drawNoard.lineColor = [UIColor blueColor];
    [self ClosePalette];
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
        NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}


- (IBAction)baocun:(id)sender {
    

 
    
    if ([MyPosition mainSingleton].address.length == 0) {
    }else {
        if ([self.NeedAddress isEqualToString:@"0"]) {
            [self.drawNoard AddAddress:[MyPosition mainSingleton].address];
        }else {
            
        }
    }
    
    [self ClosePalette];
    UIGraphicsBeginImageContextWithOptions(self.drawNoard.frame.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.drawNoard.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    self.drawNoard.image = image;
    [self loadImageFinished:image];
    if ([_delegate respondsToSelector:@selector(dataTransfer:)]) {
        [_delegate dataTransfer:image];
    }
 [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)quxiao:(id)sender {
    [self ClosePalette];
    [self.navigationController popViewControllerAnimated:YES];
    

}
//橡皮擦
- (IBAction)xiangpicha:(id)sender {
    self.drawNoard.brush = [LXFEraserBrush new];
    // 调整笔刷大小
    self.drawNoard.style.lineColor = self.drawNoard.backgroundColor;
    [self ClosePalette];
}
//更多颜色
- (IBAction)moreColor:(id)sender {
    
    [UIView animateWithDuration:1.2 animations:^{
            _colorPaint.frame = CGRectMake((kScreen_widht-200)/2, 64, 200, 200);
    }];
}
//编辑线条
- (IBAction)editLine:(UIButton *)sender {
    
    self.progressBar.hidden = sender.selected;
    
}

#pragma mark - LXFDrawBoardDelegate
- (NSString *)LXFDrawBoard:(LXFDrawBoard *)drawBoard textForDescLabel:(UILabel *)descLabel {
    return self.desc;
}

- (void)LXFDrawBoard:(LXFDrawBoard *)drawBoard clickDescLabel:(UILabel *)descLabel {
    descLabel ? self.desc = descLabel.text: nil;
    [self alterDrawBoardDescLabel];
}

- (void)alterDrawBoardDescLabel {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加描述" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.desc = alertController.textFields.firstObject.text;
        [self.drawNoard alterDescLabel];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入";
        textField.text = self.desc;
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}
//关闭调色剂
- (void)ClosePalette {
    
    [UIView animateWithDuration:1.2 animations:^{
        _colorPaint.frame = CGRectMake((kScreen_widht-200)/2, -200, 200, 200);
    }];
    
}

@end
