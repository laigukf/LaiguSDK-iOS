//
//  LGShareTransitioningDelegateImpl.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/3/20.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LGShareTransitioningDelegateImpl : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning> *interactiveTransitioning;

- (void)finishTransition;
@end
