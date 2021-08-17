//
//  LGRichTextViewModel.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/6/14.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGRichTextViewModel.h"
#import "LGRichTextMessage.h"
#import "LGRichTextViewCell.h"
#import "LGWebViewBubbleCell.h"
#import "LGServiceToViewInterface.h"
#import "LGWebViewController.h"
#import "LGAssetUtil.h"
#import "LGBotWebViewController.h"
#import "LGBotRichTextMessage.h"

@interface LGRichTextViewModel()

@property (nonatomic, strong) LGRichTextMessage *message;

@end

@implementation LGRichTextViewModel

- (id)initCellModelWithMessage:(LGRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        self.summary = self.message.summary;
        self.iconPath = self.message.thumbnail;
        self.content = self.message.content;
    }
    return self;
}

//加载 UI 需要的数据，完成后通过 UI 绑定的 block 更新 UI
- (void)load {
    if (self.modelChanges) {
        self.modelChanges(self.message.summary, self.message.thumbnail, self.message.content);
    }
    
    __weak typeof(self)wself = self;
    [LGServiceToViewInterface downloadMediaWithUrlString:self.message.userAvatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
        if (mediaData) {
            __strong typeof (wself) sself = wself;
            sself.avartarImage = [UIImage imageWithData:mediaData];
            if (sself.avatarLoaded) {
                sself.avatarLoaded(sself.avartarImage);
            }
        }
    }];
    
    [LGServiceToViewInterface downloadMediaWithUrlString:self.message.thumbnail progress:nil completion:^(NSData *mediaData, NSError *error) {
        if (mediaData) {
            __strong typeof (wself) sself = wself;
            sself.iconImage = [UIImage imageWithData:mediaData];
            if (sself.iconLoaded) {
                sself.iconLoaded(sself.iconImage);
            }
        }
    }];
}

- (void)openFrom:(UINavigationController *)cv {
    
    LGWebViewController *webViewController;
    if ([self.message isKindOfClass:[LGBotRichTextMessage class]]) {
        webViewController = [LGBotWebViewController new];
        [(LGBotWebViewController *)webViewController setMessage:(LGBotRichTextMessage *)self.message];
        [(LGBotWebViewController *)webViewController setBotEvaluateDidTapUseful:self.botEvaluateDidTapUseful];
        [(LGBotWebViewController *)webViewController setBotEvaluateDidTapUseless:self.botEvaluateDidTapUseless];
    } else {
        webViewController = [LGWebViewController new];
    }
    
    webViewController.contentHTML = self.content;
    webViewController.title = @"图文消息";
    [cv pushViewController:webViewController animated:YES];
}


#pragma mark - 

- (void)didEvaluate {
    self.isEvaluated = true;
    if ([self.message isKindOfClass:[LGBotRichTextMessage class]]) {
        [(LGBotRichTextMessage *)self.message setIsEvaluated:self.isEvaluated];
    }
}

- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 80;
}

- (LGRichTextViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGRichTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

//- ( LGNewRichMessageCell*)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
//    return [[LGNewRichMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
//}

//- (LGWebViewBubbleCell*)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
//    return [[LGWebViewBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
//}


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
