//
//  LGTipsCellModel.m
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGTipsCellModel.h"
#import "LGChatBaseCell.h"
#import "LGTipsCell.h"
#import "LGStringSizeUtil.h"
#import "LGChatViewConfig.h"
#import "LGBundleUtil.h"



//上下两条线与cell垂直边沿的间距
static CGFloat const kLGMessageTipsLabelLineVerticalMargin = 2.0;
static CGFloat const kLGMessageTipsCellVerticalSpacing = 24.0;
static CGFloat const kLGMessageTipsCellHorizontalSpacing = 24.0;
static CGFloat const kLGMessageReplyTipsCellVerticalSpacing = 8.0;
static CGFloat const kLGMessageReplyTipsCellHorizontalSpacing = 8.0;
static CGFloat const kLGMessageTipsLineHeight = 0.5;
CGFloat const kLGMessageTipsFontSize = 13.0;

@interface LGTipsCellModel()
/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 提示文字
 */
@property (nonatomic, readwrite, copy) NSString *tipText;

/**
 * @brief 提示label的frame
 */
@property (nonatomic, readwrite, assign) CGRect tipLabelFrame;

/**
 * @brief 上线条的frame
 */
@property (nonatomic, readwrite, assign) CGRect topLineFrame;

/**
 *  是否显示上下两个线条
 */
@property (nonatomic, readwrite, assign) BOOL enableLinesDisplay;

/**
 * @brief 下线条的frame
 */
@property (nonatomic, readwrite, assign) CGRect bottomLineFrame;

/**
 * @brief 提示的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

// tip 的类型
@property (nonatomic, readwrite, assign) LGTipType tipType;

@end

@implementation LGTipsCellModel

#pragma initialize
/**
 *  根据tips内容来生成cell model
 */
- (LGTipsCellModel *)initCellModelWithTips:(NSString *)tips
                                 cellWidth:(CGFloat)cellWidth
                        enableLinesDisplay:(BOOL)enableLinesDisplay
{
    if (self = [super init]) {
        self.tipType = LGTipTypeRedirect;
        self.date = [NSDate date];
        self.tipText = tips;
        self.enableLinesDisplay = enableLinesDisplay;
        
        //tip frame
        CGFloat tipCellHoriSpacing = enableLinesDisplay ? kLGMessageTipsCellHorizontalSpacing : kLGMessageReplyTipsCellHorizontalSpacing;
        CGFloat tipCellVerSpacing = enableLinesDisplay ? kLGMessageTipsCellVerticalSpacing : kLGMessageReplyTipsCellVerticalSpacing;
        CGFloat tipsWidth = cellWidth - tipCellHoriSpacing * 2;
        CGFloat tipsHeight = [LGStringSizeUtil getHeightForText:tips withFont:[UIFont systemFontOfSize:kLGMessageTipsFontSize] andWidth:tipsWidth];
        CGRect tipLabelFrame = CGRectMake(tipCellHoriSpacing, tipCellVerSpacing, tipsWidth, tipsHeight);
        self.tipLabelFrame = tipLabelFrame;
        
        self.cellHeight = tipCellVerSpacing * 2 + tipsHeight;
        
        //上线条的frame
        CGFloat lineWidth = cellWidth;
        self.topLineFrame = CGRectMake(cellWidth/2-lineWidth/2, kLGMessageTipsLabelLineVerticalMargin, lineWidth, kLGMessageTipsLineHeight);
        
        //下线条的frame
        self.bottomLineFrame = CGRectMake(self.topLineFrame.origin.x, self.cellHeight - kLGMessageTipsLabelLineVerticalMargin - kLGMessageTipsLineHeight, lineWidth, kLGMessageTipsLineHeight);
        
        //tip的文字额外属性
        if (tips.length > 4) {
            if ([[tips substringToIndex:3] isEqualToString:@"接下来"]) {
                NSRange firstRange = [tips rangeOfString:@" "];
                NSString *subTips = [tips substringFromIndex:firstRange.location+1];
                NSRange lastRange = [subTips rangeOfString:@"为你服务"];
                NSRange agentNameRange = NSMakeRange(firstRange.location+1, lastRange.location-1);
                self.tipExtraAttributesRange = agentNameRange;
                self.tipExtraAttributes = @{
                                            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
                                            NSForegroundColorAttributeName : [LGChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                            };
            }
        }
    }
    return self;
}

/**
 *  生成留言提示的 cell，支持点击留言
 */
- (LGTipsCellModel *)initBotTipCellModelWithCellWidth:(CGFloat)cellWidth
                                              tipType:(LGTipType)tipType
{
    if (self = [super init]) {
        self.tipType = tipType;
        self.date = [NSDate date];
        if (tipType == LGTipTypeReply) {
            self.tipText = [LGBundleUtil localizedStringForKey:@"reply_tip_text"];
        } else if (tipType == LGTipTypeBotRedirect) {
            self.tipText = [LGBundleUtil localizedStringForKey:@"bot_redirect_tip_text"];
        } else if (tipType == LGTipTypeBotManualRedirect) {
            self.tipText = [LGBundleUtil localizedStringForKey:@"bot_manual_redirect_tip_text"];
        }
        self.enableLinesDisplay = false;
        
        //tip frame
        CGFloat tipsWidth = cellWidth - kLGMessageReplyTipsCellHorizontalSpacing * 2;
        CGFloat tipsHeight = [LGStringSizeUtil getHeightForText:self.tipText withFont:[UIFont systemFontOfSize:kLGMessageTipsFontSize] andWidth:tipsWidth];
        CGRect tipLabelFrame = CGRectMake(kLGMessageReplyTipsCellHorizontalSpacing, kLGMessageReplyTipsCellVerticalSpacing, tipsWidth, tipsHeight);
        self.tipLabelFrame = tipLabelFrame;
        
        self.cellHeight = kLGMessageReplyTipsCellVerticalSpacing * 2 + tipsHeight;
        
        //上线条的frame
        CGFloat lineWidth = cellWidth;
        self.topLineFrame = CGRectMake(cellWidth/2-lineWidth/2, kLGMessageTipsLabelLineVerticalMargin, lineWidth, kLGMessageTipsLineHeight);
        
        //下线条的frame
        self.bottomLineFrame = CGRectMake(self.topLineFrame.origin.x, self.cellHeight - kLGMessageTipsLabelLineVerticalMargin - kLGMessageTipsLineHeight, lineWidth, kLGMessageTipsLineHeight);
        
        //tip的文字额外属性
        NSString *tapText = tipType == LGTipTypeReply ? @"留言" : @"转人工";
        NSRange replyTextRange = [self.tipText rangeOfString:tapText];
        self.tipExtraAttributesRange = replyTextRange;
        self.tipExtraAttributes = @{
                                    NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
                                    NSForegroundColorAttributeName : [LGChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                    };
    }
    return self;
}

- (LGTipsCellModel *)initWaitingInQueueTipCellModelWithCellWidth:(CGFloat)cellWidth withIntro:(NSString *)intro position:(int)position tipType:(LGTipType)tipType {
    if (self = [super init]) {
        self.tipType = tipType;
        self.date = [NSDate date];
        self.tipText = [NSString stringWithFormat:@"%@\n%@",intro,[NSString stringWithFormat:[LGBundleUtil localizedStringForKey:@"wating_in_queue_tip_text"], position]];
        self.enableLinesDisplay = false;
        
        //tip frame
        CGFloat tipsWidth = cellWidth - kLGMessageReplyTipsCellHorizontalSpacing * 2;
        CGFloat tipsHeight = [LGStringSizeUtil getHeightForText:self.tipText withFont:[UIFont systemFontOfSize:kLGMessageTipsFontSize] andWidth:tipsWidth];
        CGRect tipLabelFrame = CGRectMake(kLGMessageReplyTipsCellHorizontalSpacing, kLGMessageReplyTipsCellVerticalSpacing, tipsWidth, tipsHeight);
        self.tipLabelFrame = tipLabelFrame;
        
        self.cellHeight = kLGMessageReplyTipsCellVerticalSpacing * 2 + tipsHeight;
        
        //上线条的frame
        CGFloat lineWidth = cellWidth;
        self.topLineFrame = CGRectMake(cellWidth/2-lineWidth/2, kLGMessageTipsLabelLineVerticalMargin, lineWidth, kLGMessageTipsLineHeight);
        
        //下线条的frame
        self.bottomLineFrame = CGRectMake(self.topLineFrame.origin.x, self.cellHeight - kLGMessageTipsLabelLineVerticalMargin - kLGMessageTipsLineHeight, lineWidth, kLGMessageTipsLineHeight);
        
        //tip的文字额外属性
        NSString *tapText = @"留言";
        NSRange replyTextRange = [self.tipText rangeOfString:tapText];
        self.tipExtraAttributesRange = replyTextRange;
        self.tipExtraAttributes = @{
                                    NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
                                    NSForegroundColorAttributeName : [LGChatViewConfig sharedConfig].chatViewStyle.btnTextColor
                                    };
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
    return [[LGTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.date;
}

- (BOOL)isServiceRelatedCell {
    return false;
}

- (NSString *)getCellMessageId {
    return @"";
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    CGFloat tipCellHoriSpacing = self.tipType == LGTipTypeRedirect ? kLGMessageTipsCellHorizontalSpacing : kLGMessageReplyTipsCellHorizontalSpacing;
    CGFloat tipCellVerSpacing = self.tipType == LGTipTypeRedirect ? kLGMessageTipsCellVerticalSpacing : kLGMessageReplyTipsCellVerticalSpacing;
    
    //tip frame
    CGFloat tipsWidth = cellWidth - tipCellHoriSpacing * 2;
    self.tipLabelFrame = CGRectMake(tipCellHoriSpacing, tipCellVerSpacing, tipsWidth, self.tipLabelFrame.size.height);
    
    //上线条的frame
    CGFloat lineWidth = cellWidth;
    self.topLineFrame = CGRectMake(cellWidth/2-lineWidth/2, kLGMessageTipsLabelLineVerticalMargin, lineWidth, kLGMessageTipsLineHeight);
    
    //下线条的frame
    self.bottomLineFrame = CGRectMake(self.topLineFrame.origin.x, self.cellHeight - kLGMessageTipsLabelLineVerticalMargin - kLGMessageTipsLineHeight, lineWidth, kLGMessageTipsLineHeight);
    
    // cell height
    self.cellHeight = self.bottomLineFrame.origin.y + self.bottomLineFrame.size.height + 0.5;
}


@end
