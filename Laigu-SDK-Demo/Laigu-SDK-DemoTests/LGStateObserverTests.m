//
//  LGStateObserverTests.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 2016/11/29.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LaiGuSDK/LaiguSDK.h>
#import <XCTest/XCTest.h>

@interface LGStateObserverTests : XCTestCase

@property (nonatomic, strong) NSString *appKey;

@end

@implementation LGStateObserverTests

- (void)setUp {
    self.appKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppKey"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    __block BOOL waitingForInitComplete = YES;
    BOOL isInitInTheAir = NO;
    do {
        if (!isInitInTheAir) {
            isInitInTheAir = YES;
            [LGManager initWithAppkey:self.appKey completion:^(NSString *clientId, NSError *error) {
                NSAssert(error == nil, @"[error localizedDescription]");
                NSAssert([clientId length] != 0, @"分配顾客 id 失败");
                waitingForInitComplete = NO;
            }];
        }
    } while (waitingForInitComplete);
}

- (void)testStateObserverSetValue {
    NSString *key = @"test";
    
    [LGManager addStateObserverWithBlock:^(LGState oldState, LGState newState, NSDictionary *value, NSError *error) {
        NSAssert(newState == LGStateQueueing, @"get new state fail");
        NSAssert([value[@"1"] isEqualToString:@"1"], @"get value fail");
        [LGManager removeStateChangeObserverWithKey:key];
    } withKey:key];
    
    [self changeStateTo:LGStateQueueing object:@{@"1":@"1"} error:nil];
}

- (void)testStateObserverSetError {
    NSString *key = @"test";
    
    [LGManager addStateObserverWithBlock:^(LGState oldState, LGState newState, NSDictionary *value, NSError *error) {
        NSAssert(newState == LGStateOffline, @"get new state fail");
        NSAssert([[error domain] isEqualToString:@"offline"], @"get error fail");
        [LGManager removeStateChangeObserverWithKey:key];
    } withKey:key];
    
    [self changeStateTo:LGStateOffline object:nil error:[NSError errorWithDomain:@"offline" code:0 userInfo:nil]];
}

- (void)changeStateTo:(LGState)state object:(id)obj error:(NSError *)error {
    SEL s;
    id o;
    Class c = NSClassFromString(@"LGStateManager");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (error) {
        s = @selector(enterState:withError:);
        o = error;
    } else {
        s = @selector(enterState:withValue:);
        o = obj;
    }
    
#pragma clang diagnostic pop
    NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[c methodSignatureForSelector:s]];
    invoke.target = c;
    invoke.selector = s;
    NSUInteger v = state;
    [invoke setArgument:&v atIndex:2];
    if (o) {
        [invoke setArgument:&o atIndex:3];
    }
    [invoke invoke];
}

@end
