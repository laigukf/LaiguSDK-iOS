//
//  LGRichTextMessage.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/6/14.
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
