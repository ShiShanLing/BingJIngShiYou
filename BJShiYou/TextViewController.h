//
//  TextViewController.h
//  JYOnLine
//
//  Created by 石山岭 on 2017/8/9.
//  Copyright © 2017年 com.vstyle. All rights reserved.
//

#import <UIKit/UIKit.h>
// 照片原图路径
#define KOriginalPhotoImagePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OriginalPhotoImages"]

// 视频URL路径
#define KVideoUrlPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"VideoURL"]
// caches路径
#define KCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
@interface TextViewController : UIViewController

/**
 *
 */
@property (nonatomic, strong) UIImage *showImage;
@end
