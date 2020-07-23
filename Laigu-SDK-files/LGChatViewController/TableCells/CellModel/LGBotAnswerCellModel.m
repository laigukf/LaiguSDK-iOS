 //
//  LGBotAnswerCellModel.m
//  LGChatViewControllerDemo
//
//  Created by ijinmao on 16/4/27.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "LGBotAnswerCellModel.h"
#import "LGBotAnswerCell.h"
#import "LGChatBaseCell.h"
#import "LGChatFileUtil.h"
#import "LGStringSizeUtil.h"
#import <UIKit/UIKit.h>
#import "LGChatViewConfig.h"
#import "LGImageUtil.h"
#import "LAIGU_TTTAttributedLabel.h"
#import "LGChatEmojize.h"
#import "LGServiceToViewInterface.h"

static CGFloat const kLGBotAnswerEvaluateBtnHeight = 40.0;
static CGFloat const kLGBotAnswerEvaluateUpperLineLeftOffset = 7.5;
static CGFloat const kLGBotAnswerEvaluateBubbleMinWidth = 144.0;


@interface LGBotAnswerCellModel()

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
 * @brief 「有用」「无用」上方的线条 frame
 */
@property (nonatomic, readwrite, assign) CGRect evaluateUpperLineFrame;

/**
 * @brief 「有用」「无用」中间的线条 frame
 */
@property (nonatomic, readwrite, assign) CGRect evaluateMiddleLineFrame;

/**
 * @brief 「有用」按钮的 frame
 */
@property (nonatomic, readwrite, assign) CGRect positiveBtnFrame;

/**
 * @brief 「无用」按钮的 frame
 */
@property (nonatomic, readwrite, assign) CGRect negativeBtnFrame;

/**
 * @brief 「留言」按钮的 frame
 */
@property (nonatomic, readwrite, assign) CGRect replyBtnFrame;

/**
 * @brief 「已反馈」按钮的 frame
 */
@property (nonatomic, readwrite, assign) CGRect evaluateDoneBtnFrame;

/**
 * @brief 是否已反馈标记
 */
@property (nonatomic, readwrite, assign) BOOL isEvaluated;

/**
 * @brief 消息的 sub type
 */
@property (nonatomic, readwrite, copy) NSString *messageSubType;

/**
 * @brief 普通类型的集合
 */
@property (nonatomic, readwrite, copy) NSArray *normalSubTypes;

@end

@implementation LGBotAnswerCellModel

- (LGBotAnswerCellModel *)initCellModelWithMessage:(LGBotAnswerMessage *)message
                                    cellWidth:(CGFloat)cellWidth
                                     delegate:(id<LGCellModelDelegate>)delegator
{
    if (self = [super init]) {
        self.normalSubTypes = @[@"redirect", @"manual_redirect"];
        self.messageSubType = message.subType;
        self.isEvaluated = message.isEvaluated;
        self.messageId = message.messageId;
        self.sendStatus = message.sendStatus;
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
        self.cellText = [[NSAttributedString alloc] initWithString:message.content ?: @"" attributes:self.cellTextAttributes];
        self.date = message.date;
        self.cellHeight = 44.0;
        self.delegate = delegator;
        if (message.userAvatarImage) {
            self.avatarImage = message.userAvatarImage;
        } else if (message.userAvatarPath.length > 0) {
            self.avatarPath = message.userAvatarPath;
            //这里使用来鼓接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_LAIGU_SDK
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
#else
            __block UIImageView *tempImageView = [UIImageView new];
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.userAvatarPath] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                self.avatarImage = tempImageView.image.copy;
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#endif
        } else {
            self.avatarImage = [LGChatViewConfig sharedConfig].incomingDefaultAvatarImage;
            if (message.fromType == LGChatMessageOutgoing) {
                self.avatarImage = [LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
            }
        }
        
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
        NSRange periodRange = [message.content rangeOfString:@"."];
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
        if (![self.normalSubTypes containsObject:self.messageSubType]) {
            bubbleHeight += kLGBotAnswerEvaluateBtnHeight;
            bubbleWidth = bubbleWidth < kLGBotAnswerEvaluateBubbleMinWidth ? kLGBotAnswerEvaluateBubbleMinWidth : bubbleWidth;
            messageTextWidth = bubbleWidth - kLGCellBubbleToTextHorizontalLargerSpacing - kLGCellBubbleToTextHorizontalSmallerSpacing;
        }
        
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
            self.textLabelFrame = CGRectMake(kLGCellBubbleToTextHorizontalSmallerSpacing, kLGCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
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
            self.textLabelFrame = CGRectMake(kLGCellBubbleToTextHorizontalLargerSpacing, kLGCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
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
        
        // button上线条 frame
        self.evaluateUpperLineFrame = CGRectMake(kLGBotAnswerEvaluateUpperLineLeftOffset, bubbleHeight-kLGBotAnswerEvaluateBtnHeight, bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset, 0.5);
        
        if ([message.subType isEqualToString:@"reply"]) {
            // 若机器人消息 sub type 为「留言」，则渲染成留言留言样式
            //「有用」button frame
            self.replyBtnFrame = CGRectMake(kLGBotAnswerEvaluateUpperLineLeftOffset, self.evaluateUpperLineFrame.origin.y, bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset, kLGBotAnswerEvaluateBtnHeight);
        } else if ([message.subType isEqualToString:@"evaluate"]) {
            // 若机器人消息 sub type 为「评价」，则渲染成评价消息样式
            
            //「有用」「无用」button中间线条 frame
            self.evaluateMiddleLineFrame = CGRectMake((bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset)/2 + kLGBotAnswerEvaluateUpperLineLeftOffset, self.evaluateUpperLineFrame.origin.y+self.evaluateUpperLineFrame.size.height, 0.5, kLGBotAnswerEvaluateBtnHeight);
            //「有用」button frame
            self.positiveBtnFrame = CGRectMake(kLGBotAnswerEvaluateUpperLineLeftOffset, self.evaluateMiddleLineFrame.origin.y, (bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset)/2, kLGBotAnswerEvaluateBtnHeight);
            //「无用」button frame
            self.negativeBtnFrame = CGRectMake(self.evaluateMiddleLineFrame.origin.x+self.evaluateMiddleLineFrame.size.width, self.evaluateMiddleLineFrame.origin.y, (bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset)/2, kLGBotAnswerEvaluateBtnHeight);
            //「已反馈」button frame
            self.evaluateDoneBtnFrame = CGRectMake(0, self.evaluateMiddleLineFrame.origin.y, bubbleWidth, kLGBotAnswerEvaluateBtnHeight);
        }
        
        //计算cell的高度
        self.cellHeight = self.bubbleImageFrame.origin.y + self.bubbleImageFrame.size.height + kLGCellAvatarToVerticalEdgeSpacing;
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
    return [[LGBotAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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
    //气泡高度
    CGFloat bubbleHeight = messageTextHeight + kLGCellBubbleToTextVerticalSpacing * 2;
    //气泡宽度
    CGFloat bubbleWidth = messageTextWidth + kLGCellBubbleToTextHorizontalLargerSpacing + kLGCellBubbleToTextHorizontalSmallerSpacing;
    if (![self.normalSubTypes containsObject:self.messageSubType]) {
        bubbleHeight += kLGBotAnswerEvaluateBtnHeight;
        bubbleWidth = bubbleWidth < kLGBotAnswerEvaluateBubbleMinWidth ? kLGBotAnswerEvaluateBubbleMinWidth : bubbleWidth;
        messageTextWidth = bubbleWidth - kLGCellBubbleToTextHorizontalLargerSpacing - kLGCellBubbleToTextHorizontalSmallerSpacing;
    }

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
        self.textLabelFrame = CGRectMake(kLGCellBubbleToTextHorizontalSmallerSpacing, kLGCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
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
    }
    //气泡图片
    self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[LGChatViewConfig sharedConfig].bubbleImageStretchInsets];
    
    
    // button上线条 frame
    self.evaluateUpperLineFrame = CGRectMake(kLGBotAnswerEvaluateUpperLineLeftOffset, bubbleHeight-kLGBotAnswerEvaluateBtnHeight, bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset, 0.5);
    
    if ([self.messageSubType isEqualToString:@"reply"]) {
        // 若机器人消息 sub type 为「留言」，则渲染成留言留言样式
        self.replyBtnFrame = CGRectMake(kLGBotAnswerEvaluateUpperLineLeftOffset, self.evaluateUpperLineFrame.origin.y, bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset, kLGBotAnswerEvaluateBtnHeight);
    } else if ([self.messageSubType isEqualToString:@"evaluate"]) {
        // 若机器人消息 sub type 为「评价」，则渲染成评价消息样式
        //「有用」「无用」button中间线条 frame
        self.evaluateMiddleLineFrame = CGRectMake((bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset)/2 + kLGBotAnswerEvaluateUpperLineLeftOffset, self.evaluateUpperLineFrame.origin.y+self.evaluateUpperLineFrame.size.height, 0.5, kLGBotAnswerEvaluateBtnHeight);
        //「有用」button frame
        self.positiveBtnFrame = CGRectMake(kLGBotAnswerEvaluateUpperLineLeftOffset, self.evaluateMiddleLineFrame.origin.y, (bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset)/2, kLGBotAnswerEvaluateBtnHeight);
        //「无用」button frame
        self.negativeBtnFrame = CGRectMake(self.evaluateMiddleLineFrame.origin.x+self.evaluateMiddleLineFrame.size.width, self.evaluateMiddleLineFrame.origin.y, (bubbleWidth-kLGBotAnswerEvaluateUpperLineLeftOffset)/2, kLGBotAnswerEvaluateBtnHeight);
        //「已反馈」button frame
        self.evaluateDoneBtnFrame = CGRectMake(0, self.evaluateMiddleLineFrame.origin.y, bubbleWidth, kLGBotAnswerEvaluateBtnHeight);
    }
}

- (void)updateOutgoingAvatarImage:(UIImage *)avatarImage {
    if (self.cellFromType == LGChatCellOutgoing) {
        self.avatarImage = avatarImage;
    }
}

- (void)didEvaluate {
    self.isEvaluated = true;
}



@end
