//
//  LGMessageFactoryHelper.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 2016/11/17.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGMessageFactoryHelper.h"
#import "LGEventMessageFactory.h"
#import "LGVisialMessageFactory.h"
#import "LGBotMessageFactory.h"

@implementation LGMessageFactoryHelper

+ (id<LGMessageFactory>)factoryWithMessageAction:(LGMessageAction)action contentType:(LGMessageContentType)contenType fromType:(LGMessageFromType)fromType {
    if (action == LGMessageActionMessage || action == LGMessageActionTicketReply || action == LGMessageActionAgentSendCard) {
        if (contenType == LGMessageContentTypeBot || (contenType == LGMessageContentTypeHybrid && fromType == LGMessageFromTypeBot)) {
            return [LGBotMessageFactory new];
        } else {
            return [LGVisialMessageFactory new];
        }
    } else {
        return [LGEventMessageFactory new];
    }
}

@end
