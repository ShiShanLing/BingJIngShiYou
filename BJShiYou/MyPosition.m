//
//  MyPosition.m
//  JYOnLine
//
//  Created by 石山岭 on 2017/10/17.
//  Copyright © 2017年 com.vstyle. All rights reserved.
//

#import "MyPosition.h"

@implementation MyPosition

+(MyPosition *)mainSingleton {
    static MyPosition  *pon = nil;
    if (pon == nil) {
        pon = [[MyPosition alloc] init];
    }
    return pon;
}

@end
