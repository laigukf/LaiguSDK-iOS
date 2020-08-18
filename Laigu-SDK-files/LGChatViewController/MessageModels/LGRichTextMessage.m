//
//  LGRichTextMessage.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/6/14.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGRichTextMessage.h"

@implementation LGRichTextMessage

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.summary = dictionary[@"summary"] ?: @"";
        self.thumbnail = dictionary[@"thumbnail"] ?: @"";
        self.content = dictionary[@"content"] ?: @"";
    }
    return self;
}

@end
