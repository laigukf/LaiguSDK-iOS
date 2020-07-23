//
//  LGCardInfo.h
//  LaiGuSDK
//
//  Created by qipeng_yuhao on 2020/5/25.
//  Copyright © 2020 LaiGu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGCardInfoMeta : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *value;

@end

typedef enum : NSUInteger {
    LGMessageCardTypeText                    = 0, // 文本
    LGMessageCardTypeDateTime                = 1, // 时间
    LGMessageCardTypeRadio                   = 2, // 单选框
    LGMessageCardTypeCheckbox                  = 3, // 复选框
    LGMessageCardTypeNone                  = 4
} LGMessageCardType;


@interface LGCardInfo : NSObject

@property (nonatomic, copy) NSString * label;

@property (nonatomic, strong) NSArray<LGCardInfoMeta *> *metaData;

@property (nonatomic, strong) NSArray<LGCardInfoMeta *> *metaInfo;

@property (nonatomic, copy) NSString * name;

@property (nonatomic, assign) NSInteger contentId;

@property (nonatomic, assign) LGMessageCardType cardType;


- (id)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
