//
//  LGMessageFormViewStyleDark.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/5/24.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGMessageFormViewStyleDark.h"

@implementation LGMessageFormViewStyleDark

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor colorWithHexString:midnightBlue];
        self.navTitleColor = [UIColor colorWithHexString:gallery];
        self.navBarTintColor = [UIColor colorWithHexString:clouds];
    }
    return self;
}

@end
