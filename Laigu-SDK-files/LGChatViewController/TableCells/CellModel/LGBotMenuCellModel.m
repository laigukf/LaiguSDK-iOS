//
//  LGBotMenuCellModel.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 16/4/27.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGBotMenuCellModel.h"
#import "LGBotMenuCell.h"
#import "LGChatBaseCell.h"
#import "LGChatFileUtil.h"
#import "LGStringSizeUtil.h"
#import <UIKit/UIKit.h>
#import "LGChatViewConfig.h"
#import "LGImageUtil.h"
#import "TTTAttributedLabel.h"
#import "LGChatEmojize.h"
#import "LGServiceToViewInterface.h"
#ifndef INCLUDE_LAIGU_SDK
#import "UIImageView+WebCache.h"
#endif


@interface LGBotMenuCellModel()

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readwrite, strong) NSString *messageId;

/**
 * @brief 消息的文字
 */
@property (nonatomic, readwrite, copy) NSAttributedString *cellText;

/**
 * @brief 消息的文字属性
 */
@property (nonatomic, readwrite, copy) NSDictionary *cellTextAttributes;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片名字
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 用户名字，暂时没用
 */
@property (nonatomic, readwrite, copy) NSString *userName;

/**
 * @brief 聊天气泡的image
 */
@property (nonatomic, readwrite, copy) UIImage *bubbleImage;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleImageFrame;

/**
 * @brief 消息气泡中的文字的frame
 */
@property (nonatomic, readwrite, assign) CGRect textLabelFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 发送出错图片的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendFailureFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) LGChatCellFromType cellFromType;

/**
 * @brief 消息文字中，数字选中识别的字典 [number : range]
 */
@property (nonatomic, readwrite, strong) NSDictionary *numberRangeDic;

/**
 * @brief 消息文字中，url选中识别的字典 [url : range]
 */
@property (nonatomic, readwrite, strong) NSDictionary *linkNumberRangeDic;

/**
 * @brief 消息文字中，email选中识别的字典 [email : range]
 */
@property (nonatomic, readwrite, strong) NSDictionary *emailNumberRangeDic;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 「点击问题查看答案」label frame
 */
@property (nonatomic, readwrite, assign) CGRect replyTipLabelFrame;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

@end

@implementation LGBotMenuCellModel

- (LGBotMenuCellModel *)initCellModelWithMessage:(LGBotMenuMessage *)message
                                    cellWidth:(CGFloat)cellWidth
                                     delegate:(id<LGCellModelDelegate>)delegator
{
    if (self = [super init]) {
        self.messageId = message.messageId;
        self.conversionId = message.conversionId;
        self.sendStatus = message.sendStatus;
        //文字最大宽度
        CGFloat maxLabelWidth = cellWidth - kLGCellAvatarToHorizontalEdgeSpacing - kLGCellAvatarDiameter - kLGCellAvatarToBubbleSpacing - kLGCellBubbleToTextHorizontalLargerSpacing - kLGCellBubbleToTextHorizontalSmallerSpacing - kLGCellBubbleMaxWidthToEdgeSpacing;
        NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        contentParagraphStyle.lineSpacing = kLGTextCellLineSpacing;
        contentParagraphStyle.lineHeightMultiple = 1.0;
        contentParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        contentParagraphStyle.alignment = NSTextAlignmentLeft;
        NSMutableDictionary *contentAttributes
        = [[NSMutableDictionary alloc]
           initWithDictionary:@{
                                NSParagraphStyleAttributeName : contentParagraphStyle,
                                NSFontAttributeName : [UIFont systemFontOfSize:kLGCellTextFontSize]
                                }];
        if (message.fromType == LGChatMessageOutgoing) {
            [contentAttributes setObject:(__bridge id)[LGChatViewConfig sharedConfig].outgoingMsgTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        } else {
            [contentAttributes setObject:(__bridge id)[LGChatViewConfig sharedConfig].incomingMsgTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        }
        self.cellTextAttributes = [[NSDictionary alloc] initWithDictionary:contentAttributes];
        if (message.richContent && message.richContent.length > 0) {
            NSString *str = [NSString stringWithFormat:@"<head><style>img{width:%f !important;height:auto}</style></head>%@",maxLabelWidth,message.richContent];
                NSAttributedString *attributeString=[[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            self.cellText = attributeString;
        } else {
            self.cellText = [[NSAttributedString alloc] initWithString:message.content attributes:self.cellTextAttributes];
        }

        self.date = message.date;
        self.cellHeight = 44.0;
        self.delegate = delegator;
        
        self.avatarImage = [LGChatViewConfig sharedConfig].incomingDefaultAvatarImage;
        if (message.fromType == LGChatMessageOutgoing) {
            self.avatarImage = [LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
        }
        
        if (message.userAvatarImage) {
            self.avatarImage = message.userAvatarImage;
        } else if (message.userAvatarPath.length > 0) {
            self.avatarPath = message.userAvatarPath;
            //这里使用来鼓接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略

            [LGServiceToViewInterface downloadMediaWithUrlString:message.userAvatarPath progress:^(float progress) {
            } completion:^(NSData *mediaData, NSError *error) {
                if (mediaData && !error) {
                    self.avatarImage = [UIImage imageWithData:mediaData];
                } else {
                    self.avatarImage = message.fromType == LGChatMessageIncoming ? [LGChatViewConfig sharedConfig].incomingDefaultAvatarImage : [LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
        }
        
        //文字高度
        CGFloat messageTextHeight = [LGStringSizeUtil getHeightForAttributedText:self.cellText textWidth:maxLabelWidth];
        //判断文字中是否有emoji
        if ([LGChatEmojize stringContainsEmoji:[self.cellText string]]) {
            NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:self.cellTextAttributes];
            CGFloat oneLineTextHeight = [LGStringSizeUtil getHeightForAttributedText:oneLineText textWidth:maxLabelWidth];
            NSInteger textLines = ceil(messageTextHeight / oneLineTextHeight);
            messageTextHeight += 8 * textLines;
        }
        //文字宽度
        CGFloat messageTextWidth = [LGStringSizeUtil getWidthForAttributedText:self.cellText textHeight:messageTextHeight];
        //#warning 注：这里textLabel的宽度之所以要增加，是因为TTTAttributedLabel的bug，在文字有"."的情况下，有可能显示不出来，开发者可以帮忙定位TTTAttributedLabel的这个bug^.^
        NSRange periodRange = [message.content rangeOfString:@"."];
        if (periodRange.location != NSNotFound) {
            messageTextWidth += 8;
        }
        if (messageTextWidth > maxLabelWidth) {
            messageTextWidth = maxLabelWidth;
        }
        
        // 各 menu 的 高度
        CGFloat menuTotalHeight = 0;
        NSMutableArray *menuHeightArray = [NSMutableArray new];
        for (NSString *menu in message.menu) {
            CGFloat menuTextHeight = [LGStringSizeUtil getHeightForText:menu withFont:[UIFont systemFontOfSize:kLGBotMenuTextSize] andWidth:maxLabelWidth];
            [menuHeightArray addObject:@(menuTextHeight)];
            menuTotalHeight += menuTextHeight + kLGBotMenuVerticalSpacingInMenus;
        }
        CGFloat replyTipHeight = 0;
        if (menuTotalHeight > 0) {
            menuTotalHeight -= kLGBotMenuVerticalSpacingInMenus;
            // 「点击回复」的提示 label 高度
            replyTipHeight = [LGStringSizeUtil getHeightForText:kLGBotMenuTipText withFont:[UIFont systemFontOfSize:kLGBotMenuReplyTipSize] andWidth:maxLabelWidth];
        }
        
        //气泡高度
        CGFloat bubbleHeight = messageTextHeight + kLGCellBubbleToTextVerticalSpacing * 2;
        if (menuTotalHeight > 0) {
            bubbleHeight += menuTotalHeight + replyTipHeight + kLGCellBubbleToTextVerticalSpacing * 2;
        }
        //气泡宽度
        CGFloat bubbleWidth = maxLabelWidth + kLGCellBubbleToTextHorizontalLargerSpacing + kLGCellBubbleToTextHorizontalSmallerSpacing;
        
        //根据消息的来源，进行处理
        UIImage *bubbleImage = [LGChatViewConfig sharedConfig].incomingBubbleImage;
        if ([LGChatViewConfig sharedConfig].incomingBubbleColor) {
            bubbleImage = [LGImageUtil convertImageColorWithImage:bubbleImage toColor:[LGChatViewConfig sharedConfig].incomingBubbleColor];
        }
        if (message.fromType == LGChatMessageOutgoing) {
            //发送出去的消息
            self.cellFromType = LGChatCellOutgoing;
            bubbleImage = [LGChatViewConfig sharedConfig].outgoingBubbleImage;
            if ([LGChatViewConfig sharedConfig].outgoingBubbleColor) {
                bubbleImage = [LGImageUtil convertImageColorWithImage:bubbleImage toColor:[LGChatViewConfig sharedConfig].outgoingBubbleColor];
            }
            
            //头像的frame
            if ([LGChatViewConfig sharedConfig].enableOutgoingAvatar) {
                self.avatarFrame = CGRectMake(cellWidth-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarDiameter, kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarDiameter, kLGCellAvatarDiameter);
            } else {
                self.avatarFrame = CGRectMake(cellWidth-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarDiameter, kLGCellAvatarToVerticalEdgeSpacing, 0, 0);
            }
            //气泡的frame
            self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarToBubbleSpacing-bubbleWidth, kLGCellAvatarToVerticalEdgeSpacing, bubbleWidth, bubbleHeight);
            //文字的frame
            self.textLabelFrame = CGRectMake(kLGCellBubbleToTextHorizontalSmallerSpacing, kLGCellBubbleToTextVerticalSpacing, maxLabelWidth, messageTextHeight);
        } else {
            //收到的消息
            self.cellFromType = LGChatCellIncoming;
            
            //头像的frame
            if ([LGChatViewConfig sharedConfig].enableIncomingAvatar) {
                self.avatarFrame = CGRectMake(kLGCellAvatarToHorizontalEdgeSpacing, kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarDiameter, kLGCellAvatarDiameter);
            } else {
                self.avatarFrame = CGRectMake(kLGCellAvatarToHorizontalEdgeSpacing, kLGCellAvatarToVerticalEdgeSpacing, 0, 0);
            }
            //气泡的frame
            self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kLGCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
            //文字的frame
            self.textLabelFrame = CGRectMake(kLGCellBubbleToTextHorizontalLargerSpacing, kLGCellBubbleToTextVerticalSpacing, maxLabelWidth, messageTextHeight);
        }
        
        // menu array frame
        CGFloat menuOrigin = self.textLabelFrame.origin.y + self.textLabelFrame.size.height + kLGCellBubbleToTextVerticalSpacing;
        NSMutableArray *menuFrames = [NSMutableArray new];
        for (NSNumber *menuHeight in menuHeightArray) {
            CGRect mFrame = CGRectMake(self.textLabelFrame.origin.x, menuOrigin, self.textLabelFrame.size.width, [menuHeight floatValue]);
            [menuFrames addObject:[NSValue valueWithCGRect:mFrame]];
            menuOrigin += mFrame.size.height + kLGBotMenuVerticalSpacingInMenus;
        }
        self.menuFrames = [[NSArray alloc] initWithArray:menuFrames];
        self.menuTitles = [[NSArray alloc] initWithArray:message.menu];
        
        // reply tip frame
        CGRect lastMenuFrame = [[self.menuFrames lastObject] CGRectValue];
        self.replyTipLabelFrame = CGRectMake(self.textLabelFrame.origin.x, lastMenuFrame.origin.y+lastMenuFrame.size.height+kLGCellBubbleToTextVerticalSpacing, self.textLabelFrame.size.width, replyTipHeight);
        
        //气泡图片
        self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[LGChatViewConfig sharedConfig].bubbleImageStretchInsets];
        
        //发送消息的indicator的frame
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kLGCellIndicatorDiameter, kLGCellIndicatorDiameter)];
        self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kLGCellBubbleToIndicatorSpacing-indicatorView.frame.size.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-indicatorView.frame.size.height/2, indicatorView.frame.size.width, indicatorView.frame.size.height);
        
        //发送失败的图片frame
        UIImage *failureImage = [LGChatViewConfig sharedConfig].messageSendFailureImage;
        CGSize failureSize = CGSizeMake(ceil(failureImage.size.width * 2 / 3), ceil(failureImage.size.height * 2 / 3));
        self.sendFailureFrame = CGRectMake(self.bubbleImageFrame.origin.x-kLGCellBubbleToIndicatorSpacing-failureSize.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-failureSize.height/2, failureSize.width, failureSize.height);
        
        //计算cell的高度
        self.cellHeight = self.bubbleImageFrame.origin.y + self.bubbleImageFrame.size.height + kLGCellAvatarToVerticalEdgeSpacing;
        
        //匹配消息文字中的正则
        //数字正则匹配
        NSMutableDictionary *numberRegexDic = [[NSMutableDictionary alloc] init];
        for (NSString *numberRegex in [LGChatViewConfig sharedConfig].numberRegexs) {
            NSRange range = [message.content rangeOfString:numberRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [numberRegexDic setValue:[NSValue valueWithRange:range] forKey:[message.content substringWithRange:range]];
            }
        }
        self.numberRangeDic = numberRegexDic;
        //链接正则匹配
        NSMutableDictionary *linkRegexDic = [[NSMutableDictionary alloc] init];
        for (NSString *linkRegex in [LGChatViewConfig sharedConfig].linkRegexs) {
            NSRange range = [message.content rangeOfString:linkRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [linkRegexDic setValue:[NSValue valueWithRange:range] forKey:[message.content substringWithRange:range]];
            }
        }
        self.linkNumberRangeDic = linkRegexDic;
        //email正则匹配
        NSMutableDictionary *emailRegexDic = [[NSMutableDictionary alloc] init];
        for (NSString *emailRegex in [LGChatViewConfig sharedConfig].emailRegexs) {
            NSRange range = [message.content rangeOfString:emailRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [emailRegexDic setValue:[NSValue valueWithRange:range] forKey:[message.content substringWithRange:range]];
            }
        }
        self.emailNumberRangeDic = emailRegexDic;
        
    }
    return self;
}

#pragma LGCellModelProtocol
- (CGFloat)getCellHeight {
    return self.cellHeight > 0 ? self.cellHeight : 0;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (LGChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGBotMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.messageId;
}

- (NSString *)getMessageConversionId {
    return self.conversionId;
}

- (void)updateCellSendStatus:(LGChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.messageId = messageId;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    //文字最大宽度
    CGFloat maxLabelWidth = cellWidth - kLGCellAvatarToHorizontalEdgeSpacing - kLGCellAvatarDiameter - kLGCellAvatarToBubbleSpacing - kLGCellBubbleToTextHorizontalLargerSpacing - kLGCellBubbleToTextHorizontalSmallerSpacing - kLGCellBubbleMaxWidthToEdgeSpacing;
    //文字高度
    CGFloat messageTextHeight = [LGStringSizeUtil getHeightForAttributedText:self.cellText textWidth:maxLabelWidth];
    //判断文字中是否有emoji
    if ([LGChatEmojize stringContainsEmoji:[self.cellText string]]) {
        NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:self.cellTextAttributes];
        CGFloat oneLineTextHeight = [LGStringSizeUtil getHeightForAttributedText:oneLineText textWidth:maxLabelWidth];
        NSInteger textLines = ceil(messageTextHeight / oneLineTextHeight);
        messageTextHeight += 8 * textLines;
    }
    //文字宽度
    CGFloat messageTextWidth = [LGStringSizeUtil getWidthForAttributedText:self.cellText textHeight:messageTextHeight];
    //#warning 注：这里textLabel的宽度之所以要增加，是因为TTTAttributedLabel的bug，在文字有"."的情况下，有可能显示不出来，开发者可以帮忙定位TTTAttributedLabel的这个bug^.^
    NSRange periodRange = [self.cellText.string rangeOfString:@"."];
    if (periodRange.location != NSNotFound) {
        messageTextWidth += 8;
    }
    if (messageTextWidth > maxLabelWidth) {
        messageTextWidth = maxLabelWidth;
    }
    
    // 各 menu 的 高度
    CGFloat menuTotalHeight = 0;
    NSMutableArray *menuHeightArray = [NSMutableArray new];
    for (NSString *menu in self.menuTitles) {
        CGFloat menuTextHeight = [LGStringSizeUtil getHeightForText:menu withFont:[UIFont systemFontOfSize:kLGBotMenuTextSize] andWidth:maxLabelWidth];
        [menuHeightArray addObject:@(menuTextHeight)];
        menuTotalHeight += menuTextHeight + kLGBotMenuVerticalSpacingInMenus;
    }
    CGFloat replyTipHeight = 0;
    if (menuTotalHeight > 0) {
        menuTotalHeight -= kLGBotMenuVerticalSpacingInMenus;
        // 「点击回复」的提示 label 高度
        replyTipHeight = [LGStringSizeUtil getHeightForText:kLGBotMenuTipText withFont:[UIFont systemFontOfSize:kLGBotMenuReplyTipSize] andWidth:maxLabelWidth];
    }
    
    //气泡高度
    CGFloat bubbleHeight = messageTextHeight + kLGCellBubbleToTextVerticalSpacing * 2;
    if (menuTotalHeight > 0) {
        bubbleHeight += menuTotalHeight + replyTipHeight + kLGCellBubbleToTextVerticalSpacing * 2;
    }
    //气泡宽度
    CGFloat bubbleWidth = maxLabelWidth + kLGCellBubbleToTextHorizontalLargerSpacing + kLGCellBubbleToTextHorizontalSmallerSpacing;
    
    //根据消息的来源，进行处理
    UIImage *bubbleImage = [LGChatViewConfig sharedConfig].incomingBubbleImage;
    if ([LGChatViewConfig sharedConfig].incomingBubbleColor) {
        bubbleImage = [LGImageUtil convertImageColorWithImage:bubbleImage toColor:[LGChatViewConfig sharedConfig].incomingBubbleColor];
    }
    if (self.cellFromType == LGChatMessageOutgoing) {
        //发送出去的消息
        bubbleImage = [LGChatViewConfig sharedConfig].outgoingBubbleImage;
        if ([LGChatViewConfig sharedConfig].outgoingBubbleColor) {
            bubbleImage = [LGImageUtil convertImageColorWithImage:self.bubbleImage toColor:[LGChatViewConfig sharedConfig].outgoingBubbleColor];
        }
        
        //头像的frame
        if ([LGChatViewConfig sharedConfig].enableOutgoingAvatar) {
            self.avatarFrame = CGRectMake(cellWidth-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarDiameter, kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarDiameter, kLGCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(cellWidth-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarDiameter, kLGCellAvatarToVerticalEdgeSpacing, 0, 0);
        }
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarToBubbleSpacing-bubbleWidth, kLGCellAvatarToVerticalEdgeSpacing, bubbleWidth, bubbleHeight);
        //文字的frame
        self.textLabelFrame = CGRectMake(kLGCellBubbleToTextHorizontalSmallerSpacing, kLGCellBubbleToTextVerticalSpacing, maxLabelWidth, messageTextHeight);
    } else {
        //收到的消息
        
        //头像的frame
        if ([LGChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kLGCellAvatarToHorizontalEdgeSpacing, kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarDiameter, kLGCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(kLGCellAvatarToHorizontalEdgeSpacing, kLGCellAvatarToVerticalEdgeSpacing, 0, 0);
        }
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kLGCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
        //文字的frame
        self.textLabelFrame = CGRectMake(kLGCellBubbleToTextHorizontalLargerSpacing, kLGCellBubbleToTextVerticalSpacing, maxLabelWidth, messageTextHeight);
    }
    //气泡图片
    self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[LGChatViewConfig sharedConfig].bubbleImageStretchInsets];
    
    // menu array frame
    CGFloat menuOrigin = self.textLabelFrame.origin.y + self.textLabelFrame.size.height + kLGCellBubbleToTextVerticalSpacing;
    NSMutableArray *menuFrames = [NSMutableArray new];
    for (NSNumber *menuHeight in menuHeightArray) {
        CGRect mFrame = CGRectMake(self.textLabelFrame.origin.x, menuOrigin, self.textLabelFrame.size.width, [menuHeight floatValue]);
        [menuFrames addObject:[NSValue valueWithCGRect:mFrame]];
        menuOrigin += mFrame.size.height + kLGBotMenuVerticalSpacingInMenus;
    }
    self.menuFrames = [[NSArray alloc] initWithArray:menuFrames];
    
    // reply tip frame
    CGRect lastMenuFrame = [[self.menuFrames lastObject] CGRectValue];
    self.replyTipLabelFrame = CGRectMake(self.textLabelFrame.origin.x, lastMenuFrame.origin.y+lastMenuFrame.size.height+kLGCellBubbleToTextVerticalSpacing, self.textLabelFrame.size.width, replyTipHeight);
}

- (void)updateOutgoingAvatarImage:(UIImage *)avatarImage {
    if (self.cellFromType == LGChatCellOutgoing) {
        self.avatarImage = avatarImage;
    }
}


@end
