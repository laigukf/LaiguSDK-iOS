//
//  LGEventMessageFactory.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 2016/11/17.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGEventMessageFactory.h"
#import "LGEventMessage.h"
#import "LGBundleUtil.h"

@implementation LGEventMessageFactory

- (LGBaseMessage *)createMessage:(LGMessage *)plainMessage {
    NSString *eventContent = @"";
    LGChatEventType eventType = LGChatEventTypeInitConversation;
    switch (plainMessage.action) {
        case LGMessageActionInitConversation:
        {
            eventContent = @"您进入了客服对话";
            eventType = LGChatEventTypeInitConversation;
            break;
        }
        case LGMessageActionAgentDidCloseConversation:
        {
            eventContent = @"客服结束了此条对话";
            eventType = LGChatEventTypeAgentDidCloseConversation;
            break;
        }
        case LGMessageActionEndConversationTimeout:
        {
            eventContent = @"对话超时，系统自动结束了对话";
            eventType = LGChatEventTypeEndConversationTimeout;
            break;
        }
        case LGMessageActionRedirect:
        {
            eventContent = @"您的对话被转接给了其他客服";
            eventType = LGChatEventTypeRedirect;
            break;
        }
        case LGMessageActionAgentInputting:
        {
            eventContent = @"客服正在输入...";
            eventType = LGChatEventTypeAgentInputting;
            break;
        }
        case LGMessageActionInviteEvaluation:
        {
            eventContent = @"客服邀请您评价刚才的服务";
            eventType = LGChatEventTypeInviteEvaluation;
            break;
        }
        case LGMessageActionClientEvaluation:
        {
            eventContent = @"顾客评价结果";
            eventType = LGChatEventTypeClientEvaluation;
            break;
        }
        case LGMessageActionAgentUpdate:
        {
            eventContent = @"客服状态发生改变";
            eventType = LGChatEventTypeAgentUpdate;
            break;
        }
        case LGMessageActionListedInBlackList:
        {
            eventContent = [LGBundleUtil localizedStringForKey:@"message_tips_online_failed_listed_in_black_list"];
            eventType = LGChatEventTypeAgentUpdate;
            break;
        }
        case LGMessageActionQueueingRemoved:
        {
            eventContent = @"queue remove";
            eventType = LGChatEventTypeQueueingRemoved;
            break;
        }
        case LGMessageActionQueueingAdd:
        {
            eventContent = @"queue add";
            eventType = LGChatEventTypeQueueingAdd;
            break;
        }
        case LGMessageActionWithdrawMessage:
        {
            eventContent = @"消息撤回";
            eventType = LGChatEventTypeWithdrawMsg;
            break;
        }
        default:
            break;
    }
    if (eventContent.length == 0) {
        return nil;
    }
    LGEventMessage *toMessage = [[LGEventMessage alloc] initWithEventContent:eventContent eventType:eventType];
    toMessage.messageId = plainMessage.messageId;
    toMessage.date = plainMessage.createdOn;
    toMessage.content = eventContent;
    toMessage.userName = plainMessage.agent.nickname;
    toMessage.cardData = plainMessage.cardData;
    
    if (plainMessage.action == LGMessageActionListedInBlackList) {
        toMessage.eventType = LGChatEventTypeBackList;
    }
    
    return toMessage;
}

@end
