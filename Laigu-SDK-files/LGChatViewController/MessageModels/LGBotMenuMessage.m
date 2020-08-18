//
//  LGBotMenuMessage.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 16/4/27.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
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
