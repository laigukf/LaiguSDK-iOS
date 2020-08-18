//
//  LGTransitioningAnimation.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/3/20.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGAnimatorPush.h"
#import "LGShareTransitioningDelegateImpl.h"
#import "LGChatViewConfig.h"

@interface LGTransitioningAnimation : NSObject

+ (id <UIViewControllerTransitioningDelegate>)transitioningDelegateImpl;

+ (CATransition *)createPresentingTransiteAnimation:(LGTransiteAnimationType)animation;

+ (CATransition *)createDismissingTransiteAnimation:(LGTransiteAnimationType)animation;

+ (void)setInteractive:(BOOL)interactive;

+ (BOOL)isInteractive;

+ (void)updateInteractiveTransition:(CGFloat)percent;

+ (void)cancelInteractiveTransition;

+ (void)finishInteractiveTransition;

@end
