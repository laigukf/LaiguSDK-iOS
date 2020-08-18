//
//  LGDefinition.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/27.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

#define stringify(arg) (@""#arg)
#define recordError(e) { [LGDataCache sharedCache].globalError = e; }

typedef NS_ENUM(NSUInteger, LGState) {
    LGStateUninitialized,
    LGStateInitialized,
    LGStateOffline, // not using
    LGStateUnallocatedAgent,
    LGStateAllocatingAgent,// 正在分配客服
    LGStateAllocatedAgent,
    LGStateBlacklisted,
    LGStateQueueing,
};
typedef void (^StateChangeBlock)(LGState oldState, LGState newState, NSDictionary *value, NSError *error);

/**
 *  来鼓客服系统当前有新消息，开发者可实现该协议方法，通过此方法显示小红点未读标识
 */
#define LG_RECEIVED_NEW_MESSAGES_NOTIFICATION @"LG_RECEIVED_NEW_MESSAGES_NOTIFICATION"

/**
 *  收到该通知，即表示来鼓的通信接口出错，通信连接断开
 */

#define LG_COMMUNICATION_FAILED_NOTIFICATION @"LG_COMMUNICATION_FAILED_NOTIFICATION"

/**
 *  收到该通知，即表示顾客成功上线来鼓系统
 */
#define LG_CLIENT_ONLINE_SUCCESS_NOTIFICATION @"LG_CLIENT_ONLINE_SUCCESS_NOTIFICATION"

/**
 *  来鼓的错误码
 */
#define LGRequesetErrorDomain @"com.laigu.error.resquest.error"


/**
 当连接的状态改变时发送的通知
 */
#define LG_NOTIFICATION_SOCKET_STATUS_CHANGE @"LG_NOTIFICATION_SOCKET_STATUS_CHANGE"
#define SOCKET_STATUS_CONNECTED @"SOCKET_STATUS_CONNECTED"
#define SOCKET_STATUS_DISCONNECTED @"SOCKET_STATUS_DISCONNECTED"

/**
 聊天窗口出现
 */
#define LG_NOTIFICATION_CHAT_BEGIN @"LG_NOTIFICATION_CHAT_BEGIN"

/**
 聊天窗口消失
 */
#define LG_NOTIFICATION_CHAT_END @"LG_NOTIFICATION_CHAT_END"

/**
 当用户从排队队列被客服接入的时候出现
 */
#define LG_NOTIFICATION_QUEUEING_END @"LG_NOTIFICATION_QUEUEING_END"

/**
 来鼓Error的code对应码
 */
typedef enum : NSInteger {
    LGErrorCodeParameterUnKnown             = -2000,    //未知错误
    LGErrorCodeParameterError               = -2001,    //参数错误
    LGErrorCodeCurrentClientNotFound        = -2003,    //当前没有顾客，请新建一个顾客后再上线
    LGErrorCodeClientNotExisted             = -2004,    //来鼓服务端没有找到对应的client
    LGErrorCodeConversationNotFound         = -2005,    //来鼓服务端没有找到该对话
    LGErrorCodePlistConfigurationError      = -2006,    //开发者App的info.plist没有增加NSExceptionDomains，请参考https://github.com/Laigu/Laigu-SDK-iOS-Demo#info.plist设置
    LGErrorCodeBlacklisted                  = -2007,    //被加入黑名单，发消息和分配对话都会失败
    LGErrorCodeSchedulerFail                = -2008,    // 分配对话失败
    LGErrorCodeUninitailized                = -2009,    // 未初始化操作
    LGErrorCodeInitializFailed              = -2010,    // 初始化失败
    LGErrorCodeBotFailToRedirectToHuman     = -3001,    // 机器人转人工失败
} LGErrorCode;

/**
 顾客上线的结果枚举类型
 */
typedef enum : NSUInteger {
    LGClientOnlineResultSuccess = 0,        //上线成功
    LGClientOnlineResultParameterError,     //上线参数错误
    LGClientOnlineResultNotScheduledAgent,   //没有可接待的客服
    LGClientOnlineResultBlacklisted,
} LGClientOnlineResult;

/**
 指定分配客服，该客服不在线后转接的逻辑
 */
typedef enum : NSUInteger {
    LGScheduleRulesRedirectNone         = 1,            //不转接给任何人
    LGScheduleRulesRedirectGroup        = 2,            //转接给组内的人
    LGScheduleRulesRedirectEnterprise   = 3             //转接给企业其他随机一个人
} LGScheduleRules;

/**
 顾客对客服的某次对话的评价
 */
typedef enum : NSUInteger {
    LGConversationEvaluationNegative    = 0,            //差评
    LGConversationEvaluationModerate    = 1,            //中评
    LGConversationEvaluationPositive    = 2             //好评
} LGConversationEvaluation;
