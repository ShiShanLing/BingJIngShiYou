//
//  LXFDrawBoard.h
//  LXFDrawBoard
//
//  Created by LXF on 2017/7/6.
//  Copyright © 2017年 LXF. All rights reserved.
//
//  GitHub: https://github.com/LinXunFeng
//  简书: http://www.jianshu.com/users/31e85e7a22a2

#import <UIKit/UIKit.h>
#import "LXFPencilBrush.h"
#import "LXFRectangleBrush.h"
#import "LXFLineBrush.h"
#import "LXFArrowBrush.h"
#import "LXFTextBrush.h"
#import "LXFDrawBoardStyle.h"

@class LXFBaseBrush;
@class LXFDrawBoard;

@protocol LXFDrawBoardDelegate <NSObject>
//传文字给内部label
- (NSString *)LXFDrawBoard:(LXFDrawBoard *)drawBoard textForDescLabel:(UILabel *)descLabel;
//文字框点击事件
- (void)LXFDrawBoard:(LXFDrawBoard *)drawBoard clickDescLabel:(UILabel *)descLabel;

@optional
- (void)touchesEndedWithLXFDrawBoard:(LXFDrawBoard *)drawBoard;

@end

@interface LXFDrawBoard : UIImageView

@property (nonatomic ,copy) void (^InterfaceClick) (NSString *);
/** 代理 */
@property(nonatomic, weak) id<LXFDrawBoardDelegate> delegate;

/** 是否可以撤销 */
@property(nonatomic, assign) BOOL canRevoke;
/** 是否可以反撤销 */
@property(nonatomic, assign) BOOL canRedo;
/** 笔刷 */
@property(nonatomic, strong) LXFBaseBrush *brush;
/** 描述文本数据 */
@property(nonatomic, strong) NSMutableArray<UILabel *> *descLabelArr;
/** 样式 */
@property(nonatomic, strong) LXFDrawBoardStyle *style;
//开放一个属性用于接收从控制器传过来的线宽
@property(nonatomic,assign)CGFloat lineWidth;
//开放一个属性接收控制器传过来的颜色
@property(nonatomic,strong) UIColor * lineColor;
- (void)revoke;
- (void)redo;
- (void)setaddImage:(UIImage *)image;
/** 触发更新描述文本 */
- (void)alterDescLabel;
//添加地址信息
- (void)AddAddress:(NSString *)addressStr;
- (void)UpdateLayout;
@end
