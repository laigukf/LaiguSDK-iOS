//
//  LGEvaluationResultCellModel.h
//  LGChatViewControllerDemo
//
//  Created by ijinmao on 16/3/1.
//  Copyright © 2016年 ijinmao. All rights reserved.
//
/**
 * LGEvaluationCellModel 定义了评价 cell 的基本类型数据，包括产生cell的内部所有view的显示数据，cell内部元素的frame等
 * @warning LGEvaluationCellModel 必须满足 LGCellModelProtocol 协议
 */
#import <Foundation/Foundation.h>
#import "LGCellModelProtocol.h"

extern CGFloat const kLGEvaluationCellFontSize;

@interface LGEvaluationResultCellModel : NSObject <LGCellModelProtocol>

/**
 *  评价的等级
 */
typedef NS_ENUM(NSUInteger, LGEvaluationType) {
    LGEvaluationTypeNegative    = 0,            //差评
    LGEvaluationTypeModerate    = 1,            //中评
    LGEvaluationTypePositive    = 2             //好评
};

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief 评价的等级
 */
@property (nonatomic, readonly, assign) LGEvaluationType evaluationType;

/**
 * @brief 评价的评论
 */
@property (nonatomic, readonly, copy) NSString *comment;

/**
 * @brief 评价的等级
 */
@property (nonatomic, readonly, copy) NSString *levelText;

/**
 * @brief 等级图片的 frame
 */
@property (nonatomic, readonly, assign) CGRect evaluationImageFrame;

/**
 * @brief 评价 level label 的 frame
 */
@property (nonatomic, readonly, assign) CGRect evaluationTextLabelFrame;

/**
 * @brief 评价等级 label 的 frame
 */
@property (nonatomic, readonly, assign) CGRect evaluationLabelFrame;

/**
 * @brief 评价评论的 frame
 */
@property (nonatomic, readonly, assign) CGRect commentLabelFrame;

/**
 * @brief 评价的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 评价 label 的 color
 */
@property (nonatomic, readonly, copy) UIColor *evaluationLabelColor;

- (LGEvaluationResultCellModel *)initCellModelWithEvaluation:(LGEvaluationType)evaluationType
                                                     comment:(NSString *)comment
                                                   cellWidth:(CGFloat)cellWidth;


@end
