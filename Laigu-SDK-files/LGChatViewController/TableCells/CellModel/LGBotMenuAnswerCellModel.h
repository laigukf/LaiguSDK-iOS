//
//  LGBotMenuAnswerCellModel.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/8/24.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGCellModelProtocol.h"

@class LGBotAnswerMessage;
@interface LGBotMenuAnswerCellModel : NSObject <LGCellModelProtocol>

@property (nonatomic, strong) NSArray *menus;
@property (nonatomic, copy) NSString *menuTitle;
@property (nonatomic, copy) NSString *menuFootnote;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL isEvaluated;
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, copy) CGFloat(^provoideCellHeight)(void);
@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);

- (instancetype)initCellModelWithMessage:(LGBotAnswerMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator;

@end
