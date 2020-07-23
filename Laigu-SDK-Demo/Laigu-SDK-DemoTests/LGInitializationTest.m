//
//  LGInitializationTest.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 2016/11/28.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <LaiGuSDK/LaiguSDK.h>

@interface LGInitializationTest : XCTestCase
@property (nonatomic, strong) NSString *appKey;
@end


@implementation LGInitializationTest

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

- (void)testInitAndGetClientId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testInitAndGetClientId"];
    
    [LGManager initWithAppkey:self.appKey completion:^(NSString *clientId, NSError *error) {
        NSAssert(error == nil, [error localizedDescription]);
        NSAssert(clientId.length > 0, @"分配顾客 id 失败");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testInitNewClient {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testInitNewClient"];
    
    [LGManager createClient:^(NSString *clientId, NSError *error) {
        NSAssert(error == nil, [error localizedDescription]);
        NSAssert(clientId.length > 0, @"分配顾客 id 失败");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

@end
