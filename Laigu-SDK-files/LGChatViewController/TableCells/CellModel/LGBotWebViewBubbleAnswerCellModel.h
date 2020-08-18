//
//  LGBotWebViewBubbleAnswerCellModel.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/9/5.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGWebViewBubbleCellModel.h"

@class LGBotRichTextMessage;
@interface LGBotWebViewBubbleAnswerCellModel : NSObject <LGCellModelProtocol>

@property (nonatomic, assign) BOOL isEvaluated;
@property (nonatomic, copy) NSString *avatarPath;
@property (nonatomic, copy) NSString *messageId;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);
@property (nonatomic, copy) CGFloat(^cellHeight)(void);

@property (nonatomic, assign) CGFloat cachedWebViewHeight;

- (id)initCellModelWithMessage:(LGBotRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator;

- (void)didEvaluate;

- (void)bind;

@end
