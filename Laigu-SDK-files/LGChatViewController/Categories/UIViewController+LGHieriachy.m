//
//  UIViewController+LGHieriachy.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/7/15.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "UIViewController+LGHieriachy.h"

@implementation UIViewController(LGHieriachy)

+ (UIViewController *)topMostViewController
{
    UIViewController *topController = [self topWindow].rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

+ (UIWindow *)topWindow
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            window.windowLevel == UIWindowLevelNormal &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    
    return [UIApplication sharedApplication].keyWindow;
}


@end
