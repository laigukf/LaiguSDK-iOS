//
//  LGBotAnswerMessage.h
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 16/4/27.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGBaseMessage.h"

@class LGBotMenuMessage;
@interface LGBotAnswerMessage : LGBaseMessage

/** 消息content */
@property (nonatomic, copy) NSString *content;

/** 机器人消息的 sub type */
@property (nonatomic, copy) NSString *subType;

/** 机器人消息是否评价 */
@property (nonatomic, assign) BOOL isEvaluated;

@property (nonatomic, strong) LGBotMenuMessage *menu;


/**
 * 用文字初始化message
 */
- (instancetype)initWithContent:(NSString *)content
                        subType:(NSString *)subType
                    isEvaluated:(BOOL)isEvaluated;

@end
