//
//  LGChatViewStyleGreen.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/3/30.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGChatViewStyleGreen.h"

@implementation LGChatViewStyleGreen

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor colorWithHexString:greenSea];
        self.navTitleColor = [UIColor colorWithHexString:gallery];
        self.navBarTintColor = [UIColor colorWithHexString:clouds];
        
        self.incomingBubbleColor = [UIColor colorWithHexString:turquoise];
        self.incomingMsgTextColor = [UIColor colorWithHexString:gallery];
        
        self.outgoingBubbleColor = [UIColor colorWithHexString:gallery];
        self.outgoingMsgTextColor = [UIColor colorWithHexString:turquoise];
        
        self.pullRefreshColor = [UIColor colorWithHexString:turquoise];
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}


@end
