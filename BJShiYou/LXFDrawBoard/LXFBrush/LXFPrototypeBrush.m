//
//  LXFPrototypeBrush.m
//  JYOnLine
//
//  Created by 石山岭 on 2017/9/25.
//  Copyright © 2017年 com.vstyle. All rights reserved.
//

#import "LXFPrototypeBrush.h"

@implementation LXFPrototypeBrush

-(void)drawInContext:(CGContextRef)ctx {
    
    CGFloat x = self.startPoint.x < self.endPoint.x ? self.startPoint.x : self.endPoint.x;
    CGFloat y = self.startPoint.y < self.endPoint.y ? self.startPoint.y : self.endPoint.y;
    CGFloat width = fabs(self.startPoint.x - self.endPoint.x);
    CGFloat height = fabs(self.startPoint.y - self.endPoint.y);
    CGRect aRect= CGRectMake(x, y, width, height);
    CGContextAddEllipseInRect(ctx, aRect); //椭圆
    CGContextDrawPath(ctx, kCGPathStroke);

}

- (BOOL)keepDrawing {
    return NO;
}

@end
