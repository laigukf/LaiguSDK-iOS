//
//  NSObject+JSON.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 16/4/7.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGJSONHelper:NSObject

+ (NSString *)JSONStringWith:(id)obj;

+ (id)createWithJSONString:(NSString *)jsonString;

@end
