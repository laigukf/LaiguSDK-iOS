//
//  LGBotAnswerMessage.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 16/4/27.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGBotAnswerMessage.h"

@implementation LGBotAnswerMessage

- (instancetype)initWithContent:(NSString *)content
                        subType:(NSString *)subType
                    isEvaluated:(BOOL)isEvaluated
{
    if (self = [super init]) {
        self.content = content;
        self.subType = subType;
        self.isEvaluated = isEvaluated;
    }
    return self;
}


@end
