//
//  LGBotMenuMessage.m
//  LGChatViewControllerDemo
//
//  Created by ijinmao on 16/4/27.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "LGBotMenuMessage.h"

@implementation LGBotMenuMessage

- (instancetype)initWithContent:(NSString *)content menu:(NSArray *)menu {
    if (self = [super init]) {
        self.content = content;
        self.menu    = menu;
    }
    return self;
}


@end
