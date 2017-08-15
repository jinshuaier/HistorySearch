//
//  TCProgressHUD.h
//  顺道嘉商家版
//
//  Created by 胡高广 on 2017/5/24.
//  Copyright © 2017年 北京同创共享网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCProgressHUD : UIView
//显示转圈加载，调用dismiss、showMessage等方法隐藏，常用于已有视图上提交加载数据
+ (void)show;

//空页面显示加载动画，常用于未创建视图时加载数据，创建控件
+ (void)showWhilePushing;

//加载动画，传YES显示空页面显示加载动画，传NO显示转圈加载动画
+ (void)showWhilePushing:(BOOL)pushing;

//显示文字，默认两秒后消失
+ (void)showMessage:(NSString *)message;

//显示文字，设置显示时长
+ (void)showMessage:(NSString *)message duration:(NSTimeInterval)duration;

//隐藏
+ (void)dismiss;
@end
