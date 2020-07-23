//
//  LGTextCellModel.m
//  LaiGuSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGTextCellModel.h"
#import "LGTextMessageCell.h"
#import "LGChatBaseCell.h"
#import "LGChatFileUtil.h"
#import "LGStringSizeUtil.h"
#import <UIKit/UIKit.h>
#import "LGChatViewConfig.h"
#import "LGImageUtil.h"
#import "LAIGU_TTTAttributedLabel.h"
#import "LGChatEmojize.h"
#import "LGServiceToViewInterface.h"
#ifndef INCLUDE_LAIGU_SDK
#import "UIImageView+WebCache.h"
#endif

/**
 * 敏感词汇提示语的长度
 */
static CGFloat const kLGTextCellSensitiveWidth = 150.0;
/**
 * 敏感词汇提示语的高度
 */
static CGFloat const kLGTextCellSensitiveHeight = 25.0;

@interface LGTextCellModel()

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
 * @brief 消息文字中，是否包含敏感词汇
 */
@property (nonatomic, readwrite, assign) BOOL isSensitive;

/**
 * @brief 敏感词汇提示语frame
 */
@property (nonatomic, readwrite, assign) CGRect sensitiveLableFrame;


@property (nonatomic, strong) TTTAttributedLabel *textLabelForHeightCalculation;

@property (nonatomic, strong) NSString *messageContent;

@end

@implementation LGTextCellModel

- (LGTextCellModel *)initCellModelWithMessage:(LGTextMessage *)message
                                    cellWidth:(CGFloat)cellWidth
                                     delegate:(id<LGCellModelDelegate>)delegator
{
    if (self = [super init]) {
        self.textLabelForHeightCalculation = [TTTAttributedLabel new];
        self.textLabelForHeightCalculation.numberOfLines = 0;
        self.messageId = message.messageId;
        self.sendStatus = message.sendStatus;
        self.isSensitive = message.isSensitive;
        self.cellFromType = message.fromType == LGChatMessageIncoming ? LGChatCellIncoming : LGChatCellOutgoing;
        self.messageContent = message.content;
        self.cellWidth = cellWidth;
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
        self.cellText = [[NSAttributedString alloc] initWithString:[LGServiceToViewInterface convertToUnicodeWithEmojiAlias:message.content] attributes:self.cellTextAttributes];
        self.date = message.date;
        self.cellHeight = 44.0;
        self.delegate = delegator;
        if (message.userAvatarImage) {
            self.avatarImage = message.userAvatarImage;
        } else if (message.userAvatarPath.length > 0) {
            self.avatarPath = message.userAvatarPath;
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
        } else {
            self.avatarImage = [LGChatViewConfig sharedConfig].incomingDefaultAvatarImage;
            if (message.fromType == LGChatMessageOutgoing) {
                self.avatarImage = [LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
            }
        }
        [self configCellWidth:cellWidth];
        //匹配消息文字中的正则
        self.numberRangeDic = [self createRegexMap:[LGChatViewConfig sharedConfig].numberRegexs for:message.content];
        self.linkNumberRangeDic = [self createRegexMap:[LGChatViewConfig sharedConfig].linkRegexs for:message.content];
        self.emailNumberRangeDic = [self createRegexMap:[LGChatViewConfig sharedConfig].emailRegexs for:message.content];
        
        //防止邮件地址被解析为连接地址
        NSMutableDictionary *tempLinkNumberRangDic = [self.linkNumberRangeDic mutableCopy];
        for ( NSString *email in self.emailNumberRangeDic.allKeys) {
            for (NSString *link in self.linkNumberRangeDic.allKeys) {
                if ([email rangeOfString:link].length != 0) {
                    [tempLinkNumberRangDic removeObjectForKey:link];
                }
            }
        }
        self.linkNumberRangeDic = tempLinkNumberRangDic;
    }
    return self;
}

- (NSDictionary *)createRegexMap:(NSArray *)regexs for:(NSString *)s {
    NSMutableDictionary *regexDic = [[NSMutableDictionary alloc] init];
    for (NSString *linkRegex in regexs) {
        
        for (NSTextCheckingResult *matchedResult in [self matchWithRegex:linkRegex in:s]) {
            if (matchedResult.range.location != NSNotFound) {
                [regexDic setValue:[NSValue valueWithRange:matchedResult.range] forKey:[s substringWithRange:matchedResult.range]];
            }
        }
    }
    return regexDic;
}

- (NSArray *)matchWithRegex:(NSString *)r in:(NSString *)string {
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:r options:(NSRegularExpressionCaseInsensitive) error:nil];
    NSArray *matchResults = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    return matchResults;
}

- (void)configCellWidth:(CGFloat)cellWidth {
    //文字最大宽度
    CGFloat maxLabelWidth = cellWidth - kLGCellAvatarToHorizontalEdgeSpacing - kLGCellAvatarDiameter - kLGCellAvatarToBubbleSpacing - kLGCellBubbleToTextHorizontalLargerSpacing - kLGCellBubbleToTextHorizontalSmallerSpacing - kLGCellBubbleMaxWidthToEdgeSpacing;
    //文字高度
    //        CGFloat messageTextHeight = [LGStringSizeUtil getHeightForAttributedText:self.cellText textWidth:maxLabelWidth];
    self.textLabelForHeightCalculation.attributedText = self.cellText;
    CGFloat messageTextHeight = [self.textLabelForHeightCalculation sizeThatFits:CGSizeMake(maxLabelWidth, MAXFLOAT)].height;
    
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
    NSRange periodRange = [self.messageContent rangeOfString:@"."];
    if (periodRange.location != NSNotFound) {
        messageTextWidth += 8;
    }
    if (messageTextWidth > maxLabelWidth) {
        messageTextWidth = maxLabelWidth;
    }
    //气泡高度
    CGFloat bubbleHeight = messageTextHeight + kLGCellBubbleToTextVerticalSpacing * 2;
    //气泡宽度
    CGFloat bubbleWidth = messageTextWidth + kLGCellBubbleToTextHorizontalLargerSpacing + kLGCellBubbleToTextHorizontalSmallerSpacing;
    
    //根据消息的来源，进行处理
    UIImage *bubbleImage = [LGChatViewConfig sharedConfig].incomingBubbleImage;
    if ([LGChatViewConfig sharedConfig].incomingBubbleColor) {
        bubbleImage = [LGImageUtil convertImageColorWithImage:bubbleImage toColor:[LGChatViewConfig sharedConfig].incomingBubbleColor];
    }
    if (self.cellFromType == LGChatMessageOutgoing) {
        //发送出去的消息
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
        self.textLabelFrame = CGRectMake(kLGCellBubbleToTextHorizontalSmallerSpacing, kLGCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
        //敏感词汇提示语的frame
        self.sensitiveLableFrame = CGRectMake(CGRectGetMaxX(self.bubbleImageFrame) - kLGTextCellSensitiveWidth, CGRectGetMaxY(self.bubbleImageFrame), kLGTextCellSensitiveWidth, self.isSensitive ? kLGTextCellSensitiveHeight : 0);
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
        self.textLabelFrame = CGRectMake(kLGCellBubbleToTextHorizontalLargerSpacing, kLGCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
        //敏感词汇提示语的frame
        self.sensitiveLableFrame = CGRectMake(CGRectGetMinX(self.bubbleImageFrame), CGRectGetMaxY(self.bubbleImageFrame), kLGTextCellSensitiveWidth, self.isSensitive ? kLGTextCellSensitiveHeight : 0);
    }
    
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
    self.cellHeight = self.bubbleImageFrame.origin.y + self.bubbleImageFrame.size.height + kLGCellAvatarToVerticalEdgeSpacing + (self.isSensitive ? kLGTextCellSensitiveHeight : 0);
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
    return [[LGTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (void)updateCellSendStatus:(LGChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.messageId = messageId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.date = messageDate;
}

-(void)updateSensitiveState:(BOOL)state cellText:(NSString *)cellText{
    self.isSensitive = state;
    self.cellText = [[NSAttributedString alloc] initWithString:[LGServiceToViewInterface convertToUnicodeWithEmojiAlias:cellText] attributes:self.cellTextAttributes];
    [self configCellWidth:self.cellWidth];
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    [self configCellWidth:cellWidth];
}

- (void)updateOutgoingAvatarImage:(UIImage *)avatarImage {
    if (self.cellFromType == LGChatCellOutgoing) {
        self.avatarImage = avatarImage;
    }
}

@end
