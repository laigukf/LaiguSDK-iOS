//
//  LGAnimatorPush.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/3/20.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LGAnimatorPush : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property (nonatomic, assign) BOOL isPresenting;

@end
