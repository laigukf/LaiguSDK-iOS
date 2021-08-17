//
//  LGMessageFormViewManager.m
//  LaiGuSDK
//
//  Created by zhangshunxing on 16/5/8.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import "LGMessageFormViewManager.h"
#import "LGTransitioningAnimation.h"
#import "LGAssetUtil.h"

@implementation LGMessageFormViewManager  {
    LGMessageFormConfig *messageFormConfig;
    LGMessageFormViewController *messageFormViewController;
}

@dynamic messageFormViewStyle;

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return messageFormConfig;
}

- (instancetype)init {
    if (self = [super init]) {
        messageFormConfig = [LGMessageFormConfig sharedConfig];
    }
    return self;
}

- (LGMessageFormViewController *)pushLGMessageFormViewControllerInViewController:(UIViewController *)viewController {
    if (messageFormConfig) {
        messageFormConfig = [LGMessageFormConfig sharedConfig];
    }
    if (!messageFormViewController) {
        messageFormViewController = [[LGMessageFormViewController alloc] initWithConfig:messageFormConfig];
    }
    [self presentOnViewController:viewController transiteAnimation:LGTransiteAnimationTypePush];
    return messageFormViewController;
}

- (LGMessageFormViewController *)presentLGMessageFormViewControllerInViewController:(UIViewController *)viewController {
    if (messageFormConfig) {
        messageFormConfig = [LGMessageFormConfig sharedConfig];
    }
    if (!messageFormViewController) {
        messageFormViewController = [[LGMessageFormViewController alloc] initWithConfig:messageFormConfig];
    }
    [self presentOnViewController:viewController transiteAnimation:LGTransiteAnimationTypeDefault];
    return messageFormViewController;
}

- (void)presentOnViewController:(UIViewController *)rootViewController transiteAnimation:(LGTransiteAnimationType)animation {
    if ([LGChatViewConfig sharedConfig].presentingAnimation == LGTransiteAnimationTypeDefault) {
        messageFormConfig.presentingAnimation = animation;
    }
    
    UIViewController *viewController = nil;
    if (animation == LGTransiteAnimationTypePush) {
        viewController = [self createNavigationControllerWithWithAnimationSupport:messageFormViewController presentedViewController:rootViewController];
        BOOL shouldUseUIKitAnimation = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [rootViewController presentViewController:viewController animated:shouldUseUIKitAnimation completion:nil];
    } else {
        viewController = [[UINavigationController alloc] initWithRootViewController:messageFormViewController];
        [self updateNavAttributesWithViewController:messageFormViewController navigationController:(UINavigationController *)viewController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [rootViewController presentViewController:viewController animated:YES completion:nil];
    }
}

- (UINavigationController *)createNavigationControllerWithWithAnimationSupport:(LGMessageFormViewController *)rootViewController presentedViewController:(UIViewController *)presentedViewController{
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [navigationController setTransitioningDelegate:[LGTransitioningAnimation transitioningDelegateImpl]];
        [navigationController setModalPresentationStyle:UIModalPresentationCustom];
    } else {
        [self updateNavAttributesWithViewController:messageFormViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        
        LGTransiteAnimationType animation = [LGChatViewConfig sharedConfig].presentingAnimation;
        if (animation == LGTransiteAnimationTypeDefault) {
            animation = messageFormConfig.presentingAnimation;
        }
        [rootViewController.view.window.layer addAnimation:[LGTransitioningAnimation createPresentingTransiteAnimation:animation] forKey:nil];
    }
    return navigationController;
}

//修改导航栏属性
- (void)updateNavAttributesWithViewController:(LGMessageFormViewController *)viewController
                         navigationController:(UINavigationController *)navigationController
                  defaultNavigationController:(UINavigationController *)defaultNavigationController
                           isPresentModalView:(BOOL)isPresentModalView {
    
    if (messageFormConfig.messageFormViewStyle.navBarTintColor) {
        navigationController.navigationBar.tintColor = messageFormConfig.messageFormViewStyle.navBarTintColor;
    } else if ([LGChatViewConfig sharedConfig].navBarTintColor) {
        navigationController.navigationBar.tintColor = [LGChatViewConfig sharedConfig].navBarTintColor;
    } else if (defaultNavigationController && defaultNavigationController.navigationBar.tintColor) {
        navigationController.navigationBar.tintColor = defaultNavigationController.navigationBar.tintColor;
    }
    
    if (messageFormConfig.messageFormViewStyle.navTitleColor) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        
        navigationController.navigationBar.titleTextAttributes = @{
                                                                   UITextAttributeTextColor : messageFormConfig.messageFormViewStyle.navTitleColor
                                                                   };
#pragma clang diagnostic pop
    } else if ([LGChatViewConfig sharedConfig].navTitleColor) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        
        navigationController.navigationBar.titleTextAttributes = @{
                                                                   UITextAttributeTextColor : [LGChatViewConfig sharedConfig].navTitleColor
                                                                   };
#pragma clang diagnostic pop
    } else if (defaultNavigationController) {
        navigationController.navigationBar.titleTextAttributes = defaultNavigationController.navigationBar.titleTextAttributes;
    }
    
    if (messageFormConfig.messageFormViewStyle.navBarColor) {
        navigationController.navigationBar.barTintColor = messageFormConfig.messageFormViewStyle.navBarColor;
    } else if ([LGChatViewConfig sharedConfig].navBarColor) {
        navigationController.navigationBar.barTintColor = [LGChatViewConfig sharedConfig].navBarColor;
    } else if (defaultNavigationController && defaultNavigationController.navigationBar.barTintColor) {
        navigationController.navigationBar.barTintColor = defaultNavigationController.navigationBar.barTintColor;
    }
    
    //导航栏左键
    UIBarButtonItem *customizedBackItem = nil;
    if ([LGChatViewConfig sharedConfig].chatViewStyle.navBackButtonImage) {
        customizedBackItem = [[UIBarButtonItem alloc]initWithImage:[LGChatViewConfig sharedConfig].chatViewStyle.navBackButtonImage style:(UIBarButtonItemStylePlain) target:viewController action:@selector(dismissMessageFormViewController)];
    }
    
    LGTransiteAnimationType animation = [LGChatViewConfig sharedConfig].presentingAnimation;
    if (animation == LGTransiteAnimationTypeDefault) {
        animation = messageFormConfig.presentingAnimation;
    }
    if (animation== LGTransiteAnimationTypeDefault) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:viewController action:@selector(dismissMessageFormViewController)];
    } else {
        viewController.navigationItem.leftBarButtonItem = customizedBackItem?: [[UIBarButtonItem alloc] initWithImage:[LGAssetUtil backArrow] style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissMessageFormViewController)];
    }
}

- (void)disappearLGMessageFromViewController {
    if (!messageFormViewController) {
        return ;
    }
    [messageFormViewController dismissMessageFormViewController];
}

- (void)setLeaveMessageIntro:(NSString *)leaveMessageIntro {
    messageFormConfig.leaveMessageIntro = leaveMessageIntro;
}

@end
