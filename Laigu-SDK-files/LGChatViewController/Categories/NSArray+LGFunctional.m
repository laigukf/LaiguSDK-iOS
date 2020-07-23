//
//  NSArray+LGFunctional.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/4/20.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "NSArray+LGFunctional.h"

@implementation NSArray(LGFunctional)

- (NSArray *)filter:(BOOL(^)(id))action {
    NSMutableArray *resultArray = [NSMutableArray new];
    for (id element in self) {
        if (action(element)) {
            [resultArray addObject:element];
        }
    }
    return resultArray;
}

- (NSArray *)map:(id(^)(id ))action {
    NSMutableArray *resultArray = [NSMutableArray new];
    for (id element in self) {
        [resultArray addObject:action(element)];
    }
    return resultArray;
}

- (id)reduce:(id)initial step:(id(^)(id current, id element))action {
    __block id value = initial;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        value = action(value, obj);
    }];
    return value;
}

@end
