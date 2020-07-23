//
//  LGShareTransitioningDelegateImpl.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/3/20.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "LGShareTransitioningDelegateImpl.h"
#import "LGAnimatorPush.h"

@implementation LGShareTransitioningDelegateImpl

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    LGAnimatorPush *animator = [LGAnimatorPush new];
    animator.isPresenting = YES;
    return animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    LGAnimatorPush *animator = [LGAnimatorPush new];
    return animator;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self.interactiveTransitioning : nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self.interactiveTransitioning : nil;
}

- (UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning> *)interactiveTransitioning {
    if (!_interactiveTransitioning) {
        _interactiveTransitioning = [LGAnimatorPush new];
    }
    return _interactiveTransitioning;
}

///At end of transitioning call this function, otherwise the transisted view controller will be kept in memory
- (void)finishTransition {
    _interactiveTransitioning = nil;
}

@end
