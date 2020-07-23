//
//  LGBotMenuWebViewBubbleAnswerCellModel.h
//  Laigu-SDK-Demo
//
//  Created by xulianpeng on 2017/9/26.
//  Copyright © 2017年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGWebViewBubbleCellModel.h"

@class LGBotRichTextMessage;
@interface LGBotMenuWebViewBubbleAnswerCellModel : NSObject<LGCellModelProtocol>

//xlp
@property (nonatomic, strong) NSArray *menus;
@property (nonatomic, copy) NSString *menuTitle;
@property (nonatomic, copy) NSString *menuFootnote;

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
