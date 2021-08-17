//
//  LGTipsCellModel.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGCellModelProtocol.h"

extern CGFloat const kLGMessageTipsFontSize;

//tip 类型
typedef NS_ENUM(NSUInteger, LGTipType) {
    LGTipTypeRedirect,
    LGTipTypeReply,
    LGTipTypeBotRedirect,
    LGTipTypeBotManualRedirect,
    LGTipTypeWaitingInQueue
};

/**
 * LGTipsCellModel定义了消息提示的基本类型数据，包括产生cell的内部所有view的显示数据，cell内部元素的frame等
 * @warning LGTipsCellModel必须满足LGCellModelProtocol协议
 */
@interface LGTipsCellModel : NSObject <LGCellModelProtocol>

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief 提示文字
 */
@property (nonatomic, readonly, copy) NSString *tipText;

/**
 * @brief 提示文字的额外属性
 */
@property (nonatomic, readonly, strong) NSArray<NSDictionary<NSString *, id> *> *tipExtraAttributes;

/**
 * @brief 提示文字的额外属性的 range 的数组
 */
@property (nonatomic, readonly, strong) NSArray<NSValue *> *tipExtraAttributesRanges;

/**
 * @brief 提示的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 提示label的frame
 */
@property (nonatomic, readonly, assign) CGRect tipLabelFrame;

/**
 * @brief 上线条的frame
 */
@property (nonatomic, readonly, assign) CGRect topLineFrame;

/**
 * @brief 下线条的frame
 */
@property (nonatomic, readonly, assign) CGRect bottomLineFrame;

/**
 *  是否显示上下两个线条
 */
@property (nonatomic, readonly, assign) BOOL enableLinesDisplay;

/**
 *  底部留言的btn的frame(tipType == MQTipTypeWaitingInQueue 才会有值)
 */
@property (nonatomic, readonly, assign) CGRect bottomBtnFrame;

/**
 *  底部bottom提示文字(tipType == MQTipTypeWaitingInQueue 才会有值)
 */
@property (nonatomic, readonly, copy) NSString *bottomBtnTitle;

/**
 *  tip 类型
 */
@property (nonatomic, readonly, assign) LGTipType tipType;

/**
 *  根据tips内容来生成cell model
 */
- (LGTipsCellModel *)initCellModelWithTips:(NSString *)tips
                                 cellWidth:(CGFloat)cellWidth
                        enableLinesDisplay:(BOOL)enableLinesDisplay;

/**
 *  生成留言提示的 cell，支持点击留言
 */
- (LGTipsCellModel *)initBotTipCellModelWithCellWidth:(CGFloat)cellWidth tipType:(LGTipType)tipType;

- (LGTipsCellModel *)initWaitingInQueueTipCellModelWithCellWidth:(CGFloat)cellWidth withIntro:(NSString *)intro ticketIntro:(NSString *)ticketIntro position:(int)position tipType:(LGTipType)tipType;

@end
