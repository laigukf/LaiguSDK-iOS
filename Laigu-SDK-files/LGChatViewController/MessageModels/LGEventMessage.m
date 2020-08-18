//
//  LGEventMessage.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/11/9.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import "LGEventMessage.h"
#import "LGBundleUtil.h"

@interface LGEventMessage()

@property (nonatomic, strong) NSDictionary *tipStringMap;

@end

@implementation LGEventMessage

- (instancetype)initWithEventContent:(NSString *)eventContent
                           eventType:(LGChatEventType)eventType
{
    if (self = [super init]) {
        self.content    = eventContent;
        self.eventType  = eventType;
    }
    return self;
}

- (NSString *)tipString {
    return [self tipStringMap][@(self.eventType)];
}

- (NSDictionary *)tipStringMap {
    if (!_tipStringMap) {
        _tipStringMap = @{
                @(LGChatEventTypeAgentDidCloseConversation):@"",
                @(LGChatEventTypeWithdrawMsg):@"",
                @(LGChatEventTypeEndConversationTimeout):@"",
                @(LGChatEventTypeRedirect):[NSString stringWithFormat:[LGBundleUtil localizedStringForKey:@"lg_direct_content"], self.userName],
                @(LGChatEventTypeClientEvaluation):@"",
                @(LGChatEventTypeInviteEvaluation):@"",
                @(LGChatEventTypeAgentUpdate):@"",
                @(LGChatEventTypeQueueingRemoved):@"",
                @(LGChatEventTypeQueueingAdd):@"",
                @(LGChatEventTypeBotRedirectHuman):@"",
                @(LGChatEventTypeBackList):[LGBundleUtil localizedStringForKey:@"message_tips_online_failed_listed_in_black_list"],
                };
    }
    
    return _tipStringMap;
}

@end
