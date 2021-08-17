//
//  LGMessageFormViewService.m
//  LaiGuSDK
//
//  Created by zhangshunxing on 16/5/9.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import "LGMessageFormViewService.h"
#import "LGServiceToViewInterface.h"

@implementation LGMessageFormViewService

+ (void)getMessageFormConfigComplete:(void (^)(LGEnterpriseConfig *config, NSError *))action {
    [LGServiceToViewInterface getEnterpriseConfigInfoWithCache:NO complete:^(LGEnterprise *enterprise, NSError *error) {
        if (enterprise && enterprise.configInfo) {
            action(enterprise.configInfo, nil);
        } else {
            action(nil, error);
        }
    }];
}

+ (void)submitMessageFormWithMessage:(NSString *)message clientInfo:(NSDictionary<NSString *,NSString *> *)clientInfo completion:(void (^)(BOOL, NSError *))completion {
    [LGServiceToViewInterface submitMessageFormWithMessage:message clientInfo:clientInfo completion:completion];
}

@end
