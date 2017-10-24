//
//  PhotoEditorsVC.h
//  JYOnLine
//
//  Created by 石山岭 on 2017/8/9.
//  Copyright © 2017年 com.vstyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoEditorsVCDelegate <NSObject>

- (void)dataTransfer:(UIImage *)image;

@end

@interface PhotoEditorsVC : UIViewController
/**
 *
 */
@property (nonatomic, strong) UIImage *showImage;

@property (nonatomic, weak)id<PhotoEditorsVCDelegate>delegate;
//0(相机)需要 1(相册)不需要
@property (nonatomic, strong)NSString *NeedAddress;
@end
