//
//  LGTypeTag.h
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 2020/5/26.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGTypeTag : NSObject

+ (NSInteger)tagWithName:(NSString *)name;

+ (NSString *)nameWithTag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
