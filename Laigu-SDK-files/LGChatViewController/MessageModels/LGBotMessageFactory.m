//
//  LGBotMessageFactory.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/8/24.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGBotMessageFactory.h"
#import "LGBotRichTextMessage.h"
#import "LGTextMessage.h"
#import <LaiGuSDK/LGManager.h>
#import "LGBotAnswerMessage.h"
#import "LGBotMenuMessage.h"
#import <LaiGuSDK/LGJSONHelper.h>

@implementation LGBotMessageFactory

- (LGBaseMessage *)createMessage:(LGMessage *)plainMessage {
    NSArray *normalTypes = @[@"evaluate", @"reply", @"redirect", @"queueing", @"manual_redirect"];
    
    NSString *subType = [plainMessage.accessoryData objectForKey:@"sub_type"] ?: @"";
    LGBaseMessage *message = nil;
    if ([[plainMessage.accessoryData objectForKey:@"content_robot"] count] > 0) {
        if ([normalTypes containsObject:subType]) {
            message = [self getNormalBotAnswerMessage:plainMessage.accessoryData subType:subType];
        } else if ([subType isEqualToString:@"menu"]) {
            message = [self getMenuBotMessage:plainMessage.accessoryData];
        } else if ([subType isEqualToString:@"message"]) {
            message = [self getTextMessage:plainMessage.accessoryData];
        }
    }
    
    message.messageId = plainMessage.messageId;
    message.date = plainMessage.createdOn;
    message.userName = plainMessage.messageUserName;
    message.userAvatarPath = plainMessage.messageAvatar;
    message.fromType = LGChatMessageIncoming;
    message.conversionId = plainMessage.conversationId;
    
    return message;
}

- (BOOL)isThisAnswerContainsMenu:(NSArray *)contentRobot {
    BOOL contains = NO;
    if ([contentRobot isKindOfClass:[NSArray class]]) {
        if (contentRobot.count > 1) {
            if ([contentRobot[1][@"type"] isEqualToString:@"related"]) {
                contains = YES;
            }
        }
    }
    
    return contains;
}

- (LGBaseMessage *)getNormalBotAnswerMessage:(NSDictionary *)data subType:(NSString *)subType {
    NSString *content = @"";
    LGBotMenuMessage *embedMenuMessage;
//    NSLog(@"====收到的信息的内容为===%@",data);
    if ([subType isEqualToString:@"queueing"]) {
        content = @"暂无空闲客服，您已进入排队等待。";
        subType = @"redirect";
    } else {
        ///目前的相关问题回答消息不考虑图文消息
        if ([self isThisAnswerContainsMenu:data[@"content_robot"]]) {
            embedMenuMessage = [self getEmbedMenuBotMessage:data[@"content_robot"][1]];
            content = [[data objectForKey:@"content_robot"] firstObject][@"text"];
            content = [LGManager convertToUnicodeWithEmojiAlias:content];
        }
        
        LGBaseMessage *message = [self tryToGetRichTextMessage:data];
        //xlp 显示富文本 修改
//        if (message && embedMenuMessage == nil) {
        if (message  != nil) {

            LGBotRichTextMessage * botRichTextMessage = (LGBotRichTextMessage *)message;
            //如果是富文本cell，直接返回
            if (embedMenuMessage) {
                botRichTextMessage.menu = embedMenuMessage;
            }
            return botRichTextMessage;
        } else {
            content = [[data objectForKey:@"content_robot"] firstObject][@"text"];
            content = [LGManager convertToUnicodeWithEmojiAlias:content];
        }
    }
    BOOL isEvaluated = [data objectForKey:@"is_evaluated"] ? [[data objectForKey:@"is_evaluated"] boolValue] : false;
    LGBotAnswerMessage *botMessage = [[LGBotAnswerMessage alloc] initWithContent:content subType:subType isEvaluated:isEvaluated];
    if (embedMenuMessage) {
        botMessage.menu = embedMenuMessage;
    }
    return botMessage;
}

- (LGBaseMessage *)getMenuBotMessage:(NSDictionary *)data {
    NSString *content = @"";
    NSString *richContent = @"";
    NSMutableArray *menu = [NSMutableArray new];
    NSArray *contentRobot = [data objectForKey:@"content_robot"] ?: [NSArray new];
    for (NSInteger i=0; i < [contentRobot count]; i++) {
        NSDictionary *subContent = [contentRobot objectAtIndex:i];
        if ([subContent objectForKey:@"rich_text"]) {
            // 强制转为富文本
            richContent = [subContent objectForKey:@"rich_text"];
        }
        if (i == 0 && [[subContent objectForKey:@"type"] isEqualToString:@"text"]) {
            content = [subContent objectForKey:@"text"];
        } else if ([[subContent objectForKey:@"type"] isEqualToString:@"menu"]) {
            NSArray *items = [subContent objectForKey:@"items"];
            for (NSDictionary *item in items) {
                NSString *menuTitle = [item objectForKey:@"text"];
                menuTitle = [LGManager convertToUnicodeWithEmojiAlias:menuTitle];
                [menu addObject:menuTitle];
            }
        }
    }
    content = [LGManager convertToUnicodeWithEmojiAlias:content];
    LGBotMenuMessage *botMessage = [[LGBotMenuMessage alloc] initWithContent:content menu:menu];
    botMessage.richContent = richContent;
    return botMessage;
}

- (LGBotMenuMessage *)getEmbedMenuBotMessage:(NSDictionary *)data {
    NSArray *items = data[@"items"];
    NSMutableArray *menu = [NSMutableArray new];
    if ([items isKindOfClass:[NSArray class]]) {
        [items enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSString *title = item[@"text"];
                if (title) {
                    [menu addObject:title];
                }
            }
        }];
    }
    
    NSString *content = data[@"text_before"] ?: @"";
    content = [LGManager convertToUnicodeWithEmojiAlias:content];
    
    return [[LGBotMenuMessage alloc] initWithContent:content menu:menu];
}

- (LGBaseMessage *)getTextMessage:(NSDictionary *)data {
    LGBaseMessage *message = [self tryToGetRichTextMessage:data];
    if (message) {
        //如果是富文本cell，直接返回
        return message;
    } else {
        NSString *content = [[data objectForKey:@"content_robot"] firstObject][@"text"];
        content = [LGManager convertToUnicodeWithEmojiAlias:content];
        LGTextMessage *textMessage = [[LGTextMessage alloc] initWithContent:content];
        return textMessage;
    }
}

- (LGBaseMessage *)tryToGetRichTextMessage:(NSDictionary *)data {
    id content = [[data objectForKey:@"content_robot"] firstObject][@"rich_text"];
    if (content) {
        LGBotRichTextMessage *botRichTextMessage;
        if ([content isKindOfClass:[NSDictionary class]]) {
            botRichTextMessage = [[LGBotRichTextMessage alloc]initWithDictionary:content];
        } else {
            botRichTextMessage = [[LGBotRichTextMessage alloc]initWithDictionary:@{@"content":content}];
        }
        botRichTextMessage.thumbnail = data[@"thumbnail"];
        botRichTextMessage.summary = data[@"thumbnail"];
        botRichTextMessage.questionId = data[@"question_id"];
        
        botRichTextMessage.subType = data[@"sub_type"];
        
        BOOL isEvaluated = [data objectForKey:@"is_evaluated"] ? [[data objectForKey:@"is_evaluated"] boolValue] : false;

        botRichTextMessage.isEvaluated = isEvaluated;
        return botRichTextMessage;
    } else {
        return nil;
    }
}
@end
