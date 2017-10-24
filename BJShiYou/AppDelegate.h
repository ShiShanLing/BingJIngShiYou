//
//  AppDelegate.h
//  BJShiYou
//
//  Created by vstyle on 15/11/9.
//  Copyright (c) 2015年 com.vstyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//解析出得数据，内部是字典类型
@property (strong,nonatomic) NSMutableArray * notes ;

// 当前标签的名字 ,currentTagName 用于存储正在解析的元素名
@property (strong ,nonatomic) NSString * currentTagName ;


@end

