//
//  LGBotWebViewBubbleAnswerCellModel.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/9/5.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGBotWebViewBubbleAnswerCellModel.h"
#import "LGBotRichTextMessage.h"
#import "LGBotWebViewBubbleAnswerCell.h"
#import "LGServiceToViewInterface.h"

@interface LGBotWebViewBubbleAnswerCellModel()

@property (nonatomic, strong)LGBotRichTextMessage *message;
@property (nonatomic, strong)UIImage *avatarImage;

@end

@implementation LGBotWebViewBubbleAnswerCellModel

- (id)initCellModelWithMessage:(LGBotRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.avatarPath = message.userAvatarPath;
        self.messageId = message.messageId;
        self.content = message.content;
        self.isEvaluated = message.isEvaluated;
        self.content = message.content;
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

- (LGBotWebViewBubbleAnswerCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGBotWebViewBubbleAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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
