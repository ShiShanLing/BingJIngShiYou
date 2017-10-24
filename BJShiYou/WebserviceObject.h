//
//  WebserviceObject.h
//  BJShiYou
//
//  Created by vstyle on 16/3/4.
//  Copyright (c) 2016年 com.vstyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebserviceObject : NSObject
/**
 *"success": true,       成功标识
 *"message": "",         失败信息
 *"get_period":1000*60*5 获取周期
 *"notice_number": 20,   通知数量
 *"title": "",           标题
 *"content": "",         内容
 *"type": "",            类型  ，暂时没用到
 *"url": "",             跳转URL
 *"time": "",            发布时间
 *"blocking_timel": ""   截止通知时间
 */
@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) NSInteger get_period;
@property (nonatomic, assign) NSInteger notice_number;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSDate *blocking_timel;


@end
