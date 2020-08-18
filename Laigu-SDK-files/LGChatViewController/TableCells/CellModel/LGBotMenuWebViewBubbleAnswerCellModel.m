//
//  LGBotMenuWebViewBubbleAnswerCellModel.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 2017/9/26.
//  Copyright © 2017年 Laigu. All rights reserved.
//

#import "LGBotMenuWebViewBubbleAnswerCellModel.h"
#import "LGBotRichTextMessage.h"
#import "LGBotMenuWebViewBubbleAnswerCell.h"
#import "LGServiceToViewInterface.h"
#import "LGBotMenuCellModel.h"
@interface LGBotMenuWebViewBubbleAnswerCellModel()

@property (nonatomic, strong)LGBotRichTextMessage *message;
@property (nonatomic, strong)UIImage *avatarImage;

@end

@implementation LGBotMenuWebViewBubbleAnswerCellModel
- (id)initCellModelWithMessage:(LGBotRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.avatarPath = message.userAvatarPath;
        self.messageId = message.messageId;
        self.content = message.content;
        self.isEvaluated = message.isEvaluated;
        self.content = message.content;
        
        self.menuFootnote = kLGBotMenuTipText;
        self.menuTitle = message.menu.content;
        self.menus = message.menu.menu;
    }
    return self;
}

- (void)bind {
    
    if (self.avatarImage) {
        if (self.avatarLoaded) {
            self.avatarLoaded(self.avatarImage);
        }
    } else {
        [LGServiceToViewInterface downloadMediaWithUrlString:self.avatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
            if (mediaData) {
                self.avatarImage = [UIImage imageWithData:mediaData];
                if (self.avatarLoaded) {
                    self.avatarLoaded(self.avatarImage);
                }
            }
        }];
    }
}

#pragma mark -

- (void)didEvaluate {
    self.isEvaluated = YES;
}

- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 200;
}

- (LGBotMenuWebViewBubbleAnswerCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGBotMenuWebViewBubbleAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
}
@end
