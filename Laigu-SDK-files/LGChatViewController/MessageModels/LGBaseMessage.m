//
//  LGBaseMessage.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/10/30.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import "LGBaseMessage.h"

@implementation LGBaseMessage

- (instancetype)init {
    if (self = [super init]) {
        self.messageId = [[NSUUID UUID] UUIDString];
        self.fromType = LGChatMessageOutgoing;
        self.date = [NSDate date];
        self.userName = @"";
        self.userAvatarPath = @"";
        self.sendStatus = LGChatMessageSendStatusSending;
    }
    return self;
}

@end
