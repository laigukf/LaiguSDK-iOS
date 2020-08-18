//
//  LGTextMessage.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/10/30.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import "LGTextMessage.h"

@implementation LGTextMessage

- (instancetype)initWithContent:(NSString *)content {
    if (self = [super init]) {
        self.content = content;
    }
    return self;
}

@end
