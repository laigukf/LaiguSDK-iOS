//
//  LGSendTextTests.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 2016/11/28.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LaiGuSDK/LaiguSDK.h>
#import <XCTest/XCTest.h>

@interface LGSendTextTests : XCTestCase
@property (nonatomic, strong) NSString *appKey;

@end

@implementation LGSendTextTests

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

- (void)testSendTextMessageBeforeOnline {
    XCTestExpectation *expectation = [self expectationWithDescription:@"sendTextMessageBeforeOnline"];
    
    [LGManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
        
        [LGManager sendTextMessageWithContent:@"testSendTextMessageBeforeOnline" completion:^(LGMessage *sendedMessage, NSError *error) {
            NSAssert(error == nil, [error description]);
            NSAssert([[[LGManager getCurrentAgent] agentId] length] != 0, @"分配客服失败");
            NSAssert([LGManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
            NSAssert([LGManager getCurrentState] == LGStateAllocatedAgent, @"状态设置错误");
            [expectation fulfill];
            [LGManager endCurrentConversationWithCompletion:nil];
        }];
    }];
    
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testSendTextMessageAfterOnline {
    XCTestExpectation *expectation = [self expectationWithDescription:@"sendTextMessageBeforeOnline"];
    
    [LGManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
        
        [LGManager setClientOnlineWithCustomizedId:[LGManager getCurrentClientId] success:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
            [LGManager sendTextMessageWithContent:@"testSendTextMessageAfterOnline" completion:^(LGMessage *sendedMessage, NSError *error) {
                NSAssert(error == nil, [error localizedDescription]);
                NSAssert([LGManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
                NSAssert([LGManager getCurrentState] == LGStateAllocatedAgent, @"状态设置错误");
                [expectation fulfill];
                [LGManager endCurrentConversationWithCompletion:nil];
            }];
        } failure:nil receiveMessageDelegate:nil];
    }];
    
    
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testSendTextMessageWhenConversationFinishedRemote {
    XCTestExpectation *expectation = [self expectationWithDescription:@"sendTextMessageBeforeOnline"];
    
    [LGManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
    
        Class c = NSClassFromString(@"LGStateManager");
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL s = @selector(enterState:withValue:);
#pragma clang diagnostic pop
        NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[c methodSignatureForSelector:s]];
        invoke.target = c;
        invoke.selector = s;
        NSUInteger v = 5;
        [invoke setArgument:&v atIndex:2];
        [invoke invoke];
        
        NSAssert([LGManager getCurrentState] == LGStateAllocatedAgent, @"测试条件错误，状态应该是 LGStateAllocatedAgent");
        
        [LGManager sendTextMessageWithContent:@"testSendTextMessageWhenConversationFinished" completion:^(LGMessage *sendedMessage, NSError *error) {
            NSAssert(error == nil, [error localizedDescription]);
            NSAssert([LGManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
            NSAssert([LGManager getCurrentState] == LGStateAllocatedAgent, @"状态设置错误");
            [expectation fulfill];
            [LGManager endCurrentConversationWithCompletion:nil];
        }];
        
    }];
    
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
    
}

@end
