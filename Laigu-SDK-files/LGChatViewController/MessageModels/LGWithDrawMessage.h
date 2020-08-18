//
//  LGWithDrawMessage.h
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 2020/5/27.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import "LGBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface LGWithDrawMessage : LGBaseMessage

/** 消息是否撤回 */
@property (nonatomic, assign) BOOL isMessageWithDraw;

/** 内容 */
@property (nonatomic, copy) NSString *content;

@end

NS_ASSUME_NONNULL_END
