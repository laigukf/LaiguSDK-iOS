//
//  LGVisialMessageFactory.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 2016/11/17.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGVisialMessageFactory.h"
#import "LGTextMessage.h"
#import "LGImageMessage.h"
#import "LGVoiceMessage.h"
#import "LGCardMessage.h"
#import "LGFileDownloadMessage.h"
#import "LGRichTextMessage.h"
#import "LGWithDrawMessage.h"
#import "LGPhotoCardMessage.h"
#import "LGJsonUtil.h"

@implementation LGVisialMessageFactory

- (LGBaseMessage *)createMessage:(LGMessage *)plainMessage {
    LGBaseMessage *toMessage;
    switch (plainMessage.contentType) {
        case LGMessageContentTypeBot: {
            // was handled by LGBotMessageFactory
            return nil;
        }
        case LGMessageContentTypeText: {
            LGTextMessage *textMessage = [[LGTextMessage alloc] initWithContent:plainMessage.content];
            textMessage.isSensitive = plainMessage.isSensitive;
            toMessage = textMessage;
            break;
        }
        case LGMessageContentTypeImage: {
            LGImageMessage *imageMessage = [[LGImageMessage alloc] initWithImagePath:plainMessage.content];
            toMessage = imageMessage;
            break;
        }
        case LGMessageContentTypeVoice: {
            LGVoiceMessage *voiceMessage = [[LGVoiceMessage alloc] initWithVoicePath:plainMessage.content];
            [voiceMessage handleAccessoryData:plainMessage.accessoryData];
            toMessage = voiceMessage;
            break;
        }
        case LGMessageContentTypeFile: {
            LGFileDownloadMessage *fileDownloadMessage = [[LGFileDownloadMessage alloc] initWithDictionary:plainMessage.accessoryData];
            toMessage = fileDownloadMessage;
            break;
        }
        case LGMessageContentTypeRichText: {
            LGRichTextMessage *richTextMessage = [[LGRichTextMessage alloc] initWithDictionary:plainMessage.accessoryData];
            toMessage = richTextMessage;
            break;
        }
        case LGMessageContentTypeCard: {
            LGCardMessage *cardMessage = [[LGCardMessage alloc] init];
            cardMessage.cardData = plainMessage.cardData;
            toMessage = cardMessage;
            break;
        }
        case LGMessageContentTypeHybrid: {
            toMessage = [self messageFromContentTypeHybrid:plainMessage toLGBaseMessage:toMessage];
            break;
        }
        default:
            break;
    }
    // 消息撤回
    if (plainMessage.isMessageWithDraw) {
        LGWithDrawMessage *withDrawMessage = [[LGWithDrawMessage alloc] init];
        withDrawMessage.isMessageWithDraw = plainMessage.isMessageWithDraw;
        withDrawMessage.content = @"消息已被客服撤回";
        toMessage = withDrawMessage;
    }
    toMessage.messageId = plainMessage.messageId;
    toMessage.date = plainMessage.createdOn;
    toMessage.userName = plainMessage.messageUserName;
    toMessage.userAvatarPath = plainMessage.messageAvatar;
    toMessage.conversionId = plainMessage.conversationId;
    switch (plainMessage.sendStatus) {
        case LGMessageSendStatusSuccess:
            toMessage.sendStatus = LGChatMessageSendStatusSuccess;
            break;
        case LGMessageSendStatusFailed:
            toMessage.sendStatus = LGChatMessageSendStatusFailure;
            break;
        case LGMessageSendStatusSending:
            toMessage.sendStatus = LGChatMessageSendStatusSending;
            break;
        default:
            break;
    }
    switch (plainMessage.fromType) {
        case LGMessageFromTypeAgent:
        {
            toMessage.fromType = LGChatMessageIncoming;
            break;
        }
        case LGMessageFromTypeClient:
        {
            toMessage.fromType = LGChatMessageOutgoing;
            break;
        }
        case LGMessageFromTypeBot:
        {
            toMessage.fromType = LGChatMessageIncoming;
            break;
        }
        default:
            break;
    }
    return toMessage;
}

- (LGBaseMessage *)messageFromContentTypeHybrid:(LGMessage *)message toLGBaseMessage:(LGBaseMessage *)baseMessage {
    NSArray *contentArr = [NSArray array];
    contentArr = [LGJsonUtil createWithJSONString:message.content];
    if (contentArr.count > 0) {
        NSDictionary *contentDic = contentArr.firstObject;
        if ([contentDic[@"type"] isEqualToString:@"photo_card"]) {
            LGPhotoCardMessage *photoCard = [[LGPhotoCardMessage alloc] initWithImagePath:contentDic[@"body"][@"pic_url"] andUrlPath:contentDic[@"body"][@"target_url"]];
            baseMessage = photoCard;
        } else if ([contentDic[@"type"] isEqualToString:@"mini_program_card"]) {

        }
    }
    return baseMessage;
}


@end
