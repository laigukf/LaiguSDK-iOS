//
//  LGChatViewController.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/28.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGChatViewConfig.h"
#import "LGChatTableView.h"
#ifdef INCLUDE_LAIGU_SDK
#import "LGServiceToViewInterface.h"
#endif

/**
 * @brief 聊天界面的ViewController
 *
 * 虽然开发者可以根据LGChatViewController暴露的接口来自定义界面，但推荐做法是通过LGChatViewManager中提供的接口，来对客服聊天界面进行自定义配置；
 */
@interface LGChatViewController : UIViewController

/**
 * @brief 聊天界面的tableView
 */
@property (nonatomic, strong) LGChatTableView *chatTableView;

/**
 * @brief 聊天界面底部的输入框view
 */
@property (nonatomic, strong) UIView *inputBarView;

/**
 * @brief 聊天界面底部的输入框view
 */
@property (nonatomic, strong) UITextView *inputBarTextView;

/**
 * 根据配置初始化客服聊天界面
 * @param manager 初始化配置
 */
- (instancetype)initWithChatViewManager:(LGChatViewConfig *)chatViewConfig;

/**
 *  关闭聊天界面
 */
- (void)dismissChatViewController;

- (void)didSelectNavigationRightButton;

#ifdef INCLUDE_LAIGU_SDK
/**
 *  聊天界面的委托方法
 */
@property (nonatomic, weak) id<LGServiceToViewInterfaceDelegate> serviceToViewDelegate;
#endif

@end
