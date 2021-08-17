//
//  LGBaseMessage.h
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/10/30.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  message的来源枚举定义
 *  LGChatMessageIncoming - 收到的消息
 *  LGChatMessageOutgoing - 发送的消息
 */
typedef NS_ENUM(NSUInteger, LGChatMessageFromType) {
    LGChatMessageIncoming,
    LGChatMessageOutgoing
};

/**
 *  message的来源枚举定义
 *  LGChatMessageIncoming - 收到的消息
 *  LGChatMessageOutgoing - 发送的消息
 */
typedef NS_ENUM(NSUInteger, LGChatMessageSendStatus) {
    LGChatMessageSendStatusSuccess,
    LGChatMessageSendStatusSending,
    LGChatMessageSendStatusFailure
};


@interface LGBaseMessage : NSObject

/** 消息的会话id */
@property (nonatomic, copy) NSString *conversionId;

/** 消息id */
@property (nonatomic, copy) NSString *messageId;

/** 消息的来源类型 */
@property (nonatomic, assign) LGChatMessageFromType fromType;

/** 消息时间 */
@property (nonatomic, copy) NSDate *date;

/** 消息发送人姓名 */
@property (nonatomic, copy) NSString *userName;

/** 消息发送人头像Path */
@property (nonatomic, copy) NSString *userAvatarPath;

/** 消息发送人头像image */
@property (nonatomic, strong) UIImage *userAvatarImage;

/** 消息发送的状态 */
@property (nonatomic, assign) LGChatMessageSendStatus sendStatus;



@end
