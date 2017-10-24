//
//  MyPosition.h
//  JYOnLine
//
//  Created by 石山岭 on 2017/10/17.
//  Copyright © 2017年 com.vstyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MyPosition : NSObject

+ (MyPosition *)mainSingleton;

@property (nonatomic ,copy)NSString * longitude;
@property (nonatomic ,copy)NSString *latitude;
@property (nonatomic ,copy)NSString *address;

@end

