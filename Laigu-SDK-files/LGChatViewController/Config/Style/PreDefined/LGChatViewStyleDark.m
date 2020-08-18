//
//  LGChatViewStyleDark.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/3/30.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGChatViewStyleDark.h"

@implementation LGChatViewStyleDark

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor colorWithHexString:midnightBlue];
        self.navTitleColor = [UIColor colorWithHexString:gallery];
        self.navBarTintColor = [UIColor colorWithHexString:clouds];
        
        self.incomingBubbleColor = [UIColor colorWithHexString:clouds];
        self.incomingMsgTextColor = [UIColor colorWithHexString:wetAsphalt];
        
        self.outgoingBubbleColor = [UIColor colorWithHexString:silver];
        self.outgoingMsgTextColor = [UIColor colorWithHexString:wetAsphalt];
        
        self.pullRefreshColor = [UIColor colorWithHexString:midnightBlue];
        
        self.backgroundColor = [UIColor colorWithHexString:midnightBlue];
        
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

@end
