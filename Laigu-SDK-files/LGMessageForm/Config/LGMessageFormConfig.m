//
//  LGMessageFormConfig.m
//  LGChatViewControllerDemo
//
//  Created by bingoogolapple on 16/5/8.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "LGMessageFormConfig.h"
#import "LGMessageFormInputModel.h"
#import "LGBundleUtil.h"

@implementation LGMessageFormConfig

+ (instancetype)sharedConfig {
    static LGMessageFormConfig *_sharedConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfig = [[LGMessageFormConfig alloc] init];
    });
    return _sharedConfig;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setConfigToDefault];
    }
    return self;
}

- (void)setConfigToDefault {
    self.leaveMessageIntro = @"";
    self.messageFormViewStyle = [LGMessageFormViewStyle defaultStyle];
}

@end
