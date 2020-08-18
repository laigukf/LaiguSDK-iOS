//
//  AppDelegate.m
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 15/11/11.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import "AppDelegate.h"
#import <LaiGuSDK/LGManager.h>
#import "LGServiceToViewInterface.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //推送注册
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert
                                                | UIUserNotificationTypeBadge
                                                | UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
#else
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
#endif
    
#pragma mark  集成第一步: 初始化,  参数:appkey
    [LGManager initWithAppkey:@"" completion:^(NSString *clientId, NSError *error) {

        if (!error) {
            NSLog(@"来鼓 SDK：初始化成功");
        } else {
            NSLog(@"error:%@",error);
        }

    }];
    
    return YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    #pragma mark  集成第二步: 进入前台 打开来鼓服务
    [LGManager openLaiguService];
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    #pragma mark  集成第三步: 进入后台 关闭来鼓服务
    [LGManager closeLaiguService];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


@end
