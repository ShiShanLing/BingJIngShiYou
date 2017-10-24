//
//  LXFEraserBrush.m
//  JYOnLine
//
//  Created by 石山岭 on 2017/9/25.
//  Copyright © 2017年 com.vstyle. All rights reserved.
//

#import "LXFEraserBrush.h"

@implementation LXFEraserBrush

- (void)drawInContext:(CGContextRef)ctx {

    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    [super drawInContext:ctx];
}

@end
