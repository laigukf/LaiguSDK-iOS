//
//  LGWithDrawMessage.h
//  LGEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/27.
//  Copyright © 2020 ijinmao. All rights reserved.
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
