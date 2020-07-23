//
//  LGOnlineTests.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 2016/11/28.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <LaiGuSDK/LaiGuSDK.h>

@interface LGOnlineTests: XCTestCase
@property (nonatomic, strong) NSString *appKey;
@end

@implementation LGOnlineTests

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

- (void)tearDown {

}

- (void)testEndConversasion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithClientId"];
    
    [LGManager setClientOnlineWithClientId:[LGManager getCurrentClientId] success:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
        [LGManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
            NSAssert(success, @"结束对话失败");
            NSAssert(error == nil, [error localizedDescription]);
            NSAssert([LGManager getCurrentAgent].agentId.length == 0, @"客服设置错误");
            NSAssert([LGManager getCurrentState] == LGStateUnallocatedAgent, @"状态设置错误");
            [expectation fulfill];
        }];
    } failure:^(NSError *error) {
        NSAssert(error == nil, [error localizedDescription]);
        [expectation fulfill];
    } receiveMessageDelegate:nil];
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testUserOnlineWithClientId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithClientId"];
    NSString *clientId = [LGManager getCurrentClientId];
    [LGManager setClientOnlineWithClientId:clientId success:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
        NSAssert(agent.agentId.length != 0, @"分配客服失败");
        NSAssert([LGManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
        NSAssert([LGManager getCurrentState] == LGStateAllocatedAgent, @"状态设置错误");
        NSAssert([[LGManager getCurrentClientId] isEqualToString:clientId], @"用户 id 错误");
        [expectation fulfill];
        [LGManager endCurrentConversationWithCompletion:nil];
    } failure:^(NSError *error) {
        NSAssert(error == nil, [error description]);
        [expectation fulfill];
    } receiveMessageDelegate:nil];
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testUserOnlineWithCustomizedId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithCustomizedId"];
    
    NSString *customizedId = [[NSUUID UUID]UUIDString];
    [LGManager setClientOnlineWithCustomizedId:customizedId success:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
        NSAssert(agent.agentId.length != 0, @"分配客服失败");
        NSAssert([LGManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
        NSAssert([LGManager getCurrentState] == LGStateAllocatedAgent, @"状态设置错误");
        NSAssert([[LGManager getCurrentCustomizedId] isEqualToString:customizedId], @"自定义用户 id 错误");
        [expectation fulfill];
        [LGManager endCurrentConversationWithCompletion:nil];
    } failure:^(NSError *error) {
        NSAssert(error == nil, [error description]);
        [expectation fulfill];
    } receiveMessageDelegate:nil];
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testUserOnlineWithCurrentId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserOnlineWithCurrentId"];
    
    [LGManager setCurrentClientOnlineWithSuccess:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
        NSAssert(agent.agentId.length != 0, @"分配客服失败");
        NSAssert([LGManager getCurrentAgent].agentId.length > 0, @"客服设置错误");
        NSAssert([LGManager getCurrentState] == LGStateAllocatedAgent, @"状态设置错误");
        [expectation fulfill];
        [LGManager endCurrentConversationWithCompletion:nil];
    } failure:^(NSError *error) {
        NSAssert(error == nil, [error description]);
        [expectation fulfill];
    } receiveMessageDelegate:nil];
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

@end
