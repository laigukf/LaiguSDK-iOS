//
//  LGLGWebViewBubbleCellModel.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGWebViewBubbleCellModel.h"
#import "LGWebViewBubbleCell.h"
#import "LGRichTextMessage.h"
#import "LGServiceToViewInterface.h"

@interface LGWebViewBubbleCellModel()

@property (nonatomic, strong)LGRichTextMessage *message;
@property (nonatomic, strong)UIImage *avatarImage;
@property (nonatomic, copy) NSString *avatarPath;

@end

@implementation LGWebViewBubbleCellModel

- (id)initCellModelWithMessage:(LGRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.content = message.content;
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

#pragma mark -


- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 200;
}

- (LGWebViewBubbleCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGWebViewBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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
