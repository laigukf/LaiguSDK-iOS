//
//  LGWindowUtil.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/6/15.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGWindowUtil.h"

@implementation LGWindowUtil

+ (UIViewController *)topController {
    for (UIWindow *window in [[[UIApplication sharedApplication]windows] reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            window.windowLevel == UIWindowLevelNormal &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds)) {
            UIViewController *topController = window.rootViewController;
            while (topController.presentedViewController) {
                topController = topController.presentedViewController;
            }
            return topController;
        }
    }
    return nil;
}

@end
