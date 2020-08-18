//
//  LGChatViewStyleBlue.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/3/30.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGChatViewStyleBlue.h"

@implementation LGChatViewStyleBlue

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor colorWithHexString:belizeHole];
        self.navTitleColor = [UIColor colorWithHexString:gallery];
        self.navBarTintColor = [UIColor colorWithHexString:clouds];
        
        self.incomingBubbleColor = [UIColor colorWithHexString:dodgerBlue];
        self.incomingMsgTextColor = [UIColor colorWithHexString:gallery];
        
        self.outgoingBubbleColor = [UIColor colorWithHexString:gallery];
        self.outgoingMsgTextColor = [UIColor colorWithHexString:dodgerBlue];
        
        self.pullRefreshColor = [UIColor colorWithHexString:belizeHole];
        
        self.backgroundColor = [UIColor whiteColor];
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

@end
