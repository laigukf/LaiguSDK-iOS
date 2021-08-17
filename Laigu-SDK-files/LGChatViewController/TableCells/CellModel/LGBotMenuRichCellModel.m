//
//  LGBotMenuRichCellModel.m
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 2020/6/1.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import "LGBotMenuRichCellModel.h"
#import "LGBotMenuRichMessageCell.h"
#import "LGServiceToViewInterface.h"

@interface LGBotMenuRichCellModel()

@end

@implementation LGBotMenuRichCellModel

- (id)initCellModelWithMessage:(LGBotMenuMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.content = message.richContent?:message.content;
        self.avatarPath = message.userAvatarPath;
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

#pragma mark - 代理方法


- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 200;
}

- (LGBotMenuRichMessageCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGBotMenuRichMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (NSString *)getMessageConversionId {
    return self.message.conversionId;
}

- (void)updateCellSendStatus:(LGChatMessageSendStatus)sendStatus {
    self.message.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.message.messageId = messageId;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.message.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
}
@end
