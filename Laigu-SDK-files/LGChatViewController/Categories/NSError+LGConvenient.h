//
//  NSError+LGConvenient.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 2017/1/19.
//  Copyright © 2017年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError(LGConvenient)

+ (NSError *)reason:(NSString *)reason;

+ (NSError *)reason:(NSString *)reason code:(NSInteger)code;

+ (NSError *)reason:(NSString *)reason code:(NSInteger) code domain:(NSString *)domain;

- (NSString *)reason;

- (NSString *)shortDescription;

@end
