//
//  LGMessageFormViewService.h
//  LaiGuSDK
//
//  Created by bingoogolapple on 16/5/9.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LaiguSDK/LGEnterprise.h>

@interface LGMessageFormViewService : NSObject

/**
 获取留言表单引导文案
 */
+ (void)getMessageFormConfigComplete:(void (^)(LGEnterpriseConfig *config, NSError *))action;

/**
 *  提交留言表单
 *
 *  @param message 留言消息
 *  @param images 图片数组
 *  @param clientInfo 顾客的信息
 *  @param completion  提交留言表单的回调
 */
+ (void)submitMessageFormWithMessage:(NSString *)message
                              images:(NSArray *)images
                          clientInfo:(NSDictionary<NSString *, NSString *>*)clientInfo
                          completion:(void (^)(BOOL success, NSError *error))completion;

@end
