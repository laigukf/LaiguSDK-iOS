//
//  LGMessageFormViewStyleBlue.m
//  Laigu-SDK-Demo
//
//  Created by bingoogol on 16/5/24.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGMessageFormViewStyleBlue.h"

@implementation LGMessageFormViewStyleBlue

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor colorWithHexString:belizeHole];
        self.navTitleColor = [UIColor colorWithHexString:gallery];
        self.navBarTintColor = [UIColor colorWithHexString:clouds];
    }
    return self;
}

@end
