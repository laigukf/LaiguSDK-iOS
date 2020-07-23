//
//  LGMessageFormConfig.h
//  LGChatViewControllerDemo
//
//  Created by bingoogolapple on 16/5/8.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGMessageFormViewStyle.h"
#import "LGChatViewConfig.h"

@interface LGMessageFormConfig : NSObject

@property (nonatomic, assign) LGTransiteAnimationType presentingAnimation;

/// 预设的聊天界面样式
@property (nonatomic, strong) LGMessageFormViewStyle *messageFormViewStyle;

/** 自定义留言表单引导文案 */
@property (nonatomic, copy) NSString *leaveMessageIntro;
/** 留言表单的自定义输入信息 */
@property (nonatomic, strong) NSArray *customMessageFormInputModelArray;

+ (instancetype)sharedConfig;

/** 将配置设置为默认值 */
- (void)setConfigToDefault;

@end
