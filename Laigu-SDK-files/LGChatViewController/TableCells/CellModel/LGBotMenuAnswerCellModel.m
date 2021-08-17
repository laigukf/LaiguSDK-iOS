//
//  LGBotMenuAnswerCellModel.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/8/24.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGBotMenuAnswerCellModel.h"
#import "LGBotAnswerMessage.h"
#import "LGBotMenuAnswerCell.h"
#import "LGBotMenuCellModel.h" //
#import "LGServiceToViewInterface.h"

@interface LGBotMenuAnswerCellModel()

@property (nonatomic, strong) LGBotAnswerMessage *message;

@end

@implementation LGBotMenuAnswerCellModel

- (instancetype)initCellModelWithMessage:(LGBotAnswerMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator {
 
    if (self = [super init]) {
        self.message = message;
        self.content = message.content;
        self.messageId = message.messageId;
        self.menuFootnote = kLGBotMenuTipText;
        self.menuTitle = message.menu.content;
        self.menus = message.menu.menu;
        self.isEvaluated = message.isEvaluated;
        
        __weak typeof(self)wself = self;
        [LGServiceToViewInterface downloadMediaWithUrlString:message.userAvatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
            if (mediaData) {
                __strong typeof (wself) sself = wself;
                sself.avatarImage = [UIImage imageWithData:mediaData];
                if (sself.avatarLoaded) {
                    sself.avatarLoaded(sself.avatarImage);
                }
            }
        }];
    }
    
    return self;
}


#pragma mark - delegate

- (CGFloat)getCellHeight {

    if (self.provoideCellHeight) {
        return self.provoideCellHeight();
    } else {
        return 200;
    }
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (LGChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGBotMenuAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.message.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.message.messageId;
}

- (void)updateCellSendStatus:(LGChatMessageSendStatus)sendStatus {
    self.message.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.message.messageId = messageId;
}

- (NSString *)getMessageConversionId {
    return self.message.conversionId;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.message.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    
}

- (void)didEvaluate {
    self.isEvaluated = YES;
}

@end
