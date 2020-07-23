//
//  LGMessageFormViewService.m
//  LaiGuSDK
//
//  Created by bingoogolapple on 16/5/9.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import "LGMessageFormViewService.h"
#import "LGServiceToViewInterface.h"

@implementation LGMessageFormViewService

+ (void)getMessageFormConfigComplete:(void (^)(LGEnterpriseConfig *config, NSError *))action {
    [LGServiceToViewInterface getMessageFormConfigComplete:action];
}

+ (void)submitMessageFormWithMessage:(NSString *)message images:(NSArray *)images clientInfo:(NSDictionary<NSString *,NSString *> *)clientInfo completion:(void (^)(BOOL, NSError *))completion {
    [LGServiceToViewInterface submitMessageFormWithMessage:message images:images clientInfo:clientInfo completion:completion];
}

@end
