//
//  NSNull+Safe.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/5/31.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "NSNull+LGSafe.h"
#import <objc/runtime.h>

@implementation NSNull(LGSafe)

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    anInvocation.target = nil;
    [anInvocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (!sig) {
        sig = [NSMethodSignature signatureWithObjCTypes:"^v^c"];
    }
    
    return sig;
}

@end
