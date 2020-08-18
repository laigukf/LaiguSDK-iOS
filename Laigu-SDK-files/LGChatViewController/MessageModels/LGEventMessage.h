//
//  LGEventMessage.h
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/11/9.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGBaseMessage.h"

typedef enum : NSUInteger {
    LGChatEventTypeInitConversation          = 0,   //初始化对话 (init_conv)
    LGChatEventTypeAgentDidCloseConversation = 1,   //客服结束对话 (end_conv_agent)
    LGChatEventTypeEndConversationTimeout    = 2,   //对话超时，系统自动结束对话 (end_conv_timeout)
    LGChatEventTypeRedirect                  = 3,   //顾客被转接 (agent_redirect)
    LGChatEventTypeAgentInputting            = 4,   //客服正在输入 (agent_inputting)
    LGChatEventTypeInviteEvaluation          = 5,    //收到客服邀请评价 (invite_evaluation)
    LGChatEventTypeClientEvaluation          = 6,    //顾客评价的结果
    LGChatEventTypeAgentUpdate               = 7,    //客服的状态发生改变
    LGChatEventTypeQueueingRemoved           = 8,    //顾客从等待客服队列中移除
    LGChatEventTypeQueueingAdd               = 9,    //顾客被添加到客服等待队列
    LGChatEventTypeBackList                  = 10,   // 被添加到黑名单
    LGChatEventTypeBotRedirectHuman          = 11,   //机器人转人工
    LGChatEventTypeWithdrawMsg               = 12,    //消息撤回
} LGChatEventType;

@interface LGEventMessage : LGBaseMessage

/** 事件content */
@property (nonatomic, copy  ) NSString *content;

/** 事件类型 */
@property (nonatomic, assign) LGChatEventType eventType;

@property (nonatomic, strong, readonly) NSString *tipString;

@property (nonatomic, strong) NSArray *cardData; // 卡片数据

/**
 * 初始化message
 */
- (instancetype)initWithEventContent:(NSString *)eventContent
                           eventType:(LGChatEventType)eventType;

@end
