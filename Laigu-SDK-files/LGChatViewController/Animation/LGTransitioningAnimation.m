//
//  LGTransitioningAnimation.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/3/20.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGTransitioningAnimation.h"

@interface LGTransitioningAnimation()

@property (nonatomic, strong) LGShareTransitioningDelegateImpl <UIViewControllerTransitioningDelegate> * transitioningDelegateImpl;

@end


@implementation LGTransitioningAnimation

///使用 singleton 的原因是使用这个 transition 的对象并没有维护这个 transition 对象，如果被释放 transition 则会失效，为了减少自定义 transition 对使用者的侵入，只好使用 singleton 来保持该对象
+ (instancetype)sharedInstance {
    static LGTransitioningAnimation *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LGTransitioningAnimation new];
    });
    
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.transitioningDelegateImpl = [LGShareTransitioningDelegateImpl new];
    }
    return self;
}

+ (void)setInteractive:(BOOL)interactive {
    [LGTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactive = interactive;
}

+ (BOOL)isInteractive {
    return [LGTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactive;
}

+ (id <UIViewControllerTransitioningDelegate>)transitioningDelegateImpl {
    return [[self sharedInstance] transitioningDelegateImpl];
}

+ (void)updateInteractiveTransition:(CGFloat)percent {
    [[LGTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning updateInteractiveTransition:percent];
}

+ (void)cancelInteractiveTransition {
    [[LGTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning cancelInteractiveTransition];
    [LGTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning = nil;
}

+ (void)finishInteractiveTransition {
    [[LGTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning finishInteractiveTransition];
    [[LGTransitioningAnimation sharedInstance].transitioningDelegateImpl finishTransition];
    
}

#pragma mark -

+ (CATransition *)createPresentingTransiteAnimation:(LGTransiteAnimationType)animation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    switch (animation) {
        case LGTransiteAnimationTypePush:
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            break;
        case LGTransiteAnimationTypeDefault:
        default:
            break;
    }
    return transition;
}
+ (CATransition *)createDismissingTransiteAnimation:(LGTransiteAnimationType)animation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    switch (animation) {
        case LGTransiteAnimationTypePush:
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromLeft;
            break;
        case LGTransiteAnimationTypeDefault:
        default:
            break;
    }
    return transition;
}


@end
