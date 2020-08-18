//
//  LGBotRickTextMessage.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/8/8.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGBotRichTextMessage.h"

@implementation LGBotRichTextMessage
- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.summary = dictionary[@"summary"] ?: @"";
        self.thumbnail = dictionary[@"thumbnail"] ?: @"";
        self.content = dictionary[@"content"] ?: @"";
    }
    return self;
}

@end
