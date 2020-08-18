//
//  LGMessageFormViewController.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 16/5/4.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGMessageFormConfig.h"

/**
 * @brief 留言表单界面的ViewController
 *
 */
@interface LGMessageFormViewController : UIViewController

/**
 * 根据配置初始化留言表单界面
 * @param manager 初始化配置
 */
- (instancetype)initWithConfig:(LGMessageFormConfig *)config;

/**
 *  关闭留言表单界面
 */
- (void)dismissMessageFormViewController;

@end
