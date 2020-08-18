//
//  NSArray+LGFunctional.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/4/20.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(LGFunctional)

- (NSArray *)filter:(BOOL(^)(id element))action;

- (NSArray *)map:(id(^)(id element))action;

- (id)reduce:(id)initial step:(id(^)(id current, id element))action;

@end
