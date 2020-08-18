//
//  LGEvaluationResultCellModel.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 16/3/1.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGEvaluationResultCellModel.h"
#import "LGEvaluationResultCell.h"
#import "LGStringSizeUtil.h"
#import "LGImageUtil.h"
#import "LGAssetUtil.h"

static CGFloat const kLGEvaluationCellLabelVerticalMargin = 6.0;
static CGFloat const kLGEvaluationCellLabelHorizontalMargin = 8.0;
static CGFloat const kLGEvaluationCellLabelHorizontalSpacing = 8.0;
static CGFloat const kLGEvaluationCellVerticalSpacing = 12.0;
static CGFloat const kLGEvaluationCommentHorizontalSpacing = 36.0;
CGFloat const kLGEvaluationCellFontSize = 14.0;

@interface LGEvaluationResultCellModel()

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 评价的等级
 */
@property (nonatomic, readwrite, assign) LGEvaluationType evaluationType;

/**
 * @brief 评价的评论
 */
@property (nonatomic, readwrite, copy) NSString *comment;

/**
 * @brief 评价的等级
 */
@property (nonatomic, readwrite, copy) NSString *levelText;

/**
 * @brief 等级图片的 frame
 */
@property (nonatomic, readwrite, assign) CGRect evaluationImageFrame;

/**
 * @brief 评价 level label 的 frame
 */
@property (nonatomic, readwrite, assign) CGRect evaluationTextLabelFrame;

/**
 * @brief 评价等级 label 的 frame
 */
@property (nonatomic, readwrite, assign) CGRect evaluationLabelFrame;

/**
 * @brief 评价评论的 frame
 */
@property (nonatomic, readwrite, assign) CGRect commentLabelFrame;

/**
 * @brief 评价的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 评价 label 的 color
 */
@property (nonatomic, readwrite, copy) UIColor *evaluationLabelColor;

@end

@implementation LGEvaluationResultCellModel

#pragma initialize
/**
 *  根据tips内容来生成cell model
 */
- (LGEvaluationResultCellModel *)initCellModelWithEvaluation:(LGEvaluationType)evaluationType
                                                     comment:(NSString *)comment
                                                   cellWidth:(CGFloat)cellWidth
{
    if (self = [super init]) {
        self.date = [NSDate date];
        self.comment = comment;
        self.evaluationType = evaluationType;
        switch (evaluationType) {
            case LGEvaluationTypeNegative:
                self.evaluationLabelColor = [UIColor colorWithRed:255.0/255.0 green:92.0/255.0 blue:94.0/255.0 alpha:1];
                self.levelText = @"差评";
                break;
            case LGEvaluationTypeModerate:
                self.evaluationLabelColor = [UIColor colorWithRed:255.0/255.0 green:182.0/255.0 blue:82.0/255.0 alpha:1];
                self.levelText = @"中评";
                break;
            case LGEvaluationTypePositive:
                self.evaluationLabelColor = [UIColor colorWithRed:0.0/255.0 green:206.0/255.0 blue:125.0/255.0 alpha:1];
                self.levelText = @"好评";
                break;
            default:
                self.evaluationLabelColor = [UIColor colorWithRed:0.0/255.0 green:206.0/255.0 blue:125.0/255.0 alpha:1];
                self.levelText = @"好评";
                break;
        }
        
        //评价的 label frame
        CGFloat levelTextWidth = [LGStringSizeUtil getWidthForText:self.levelText withFont:[UIFont systemFontOfSize:kLGEvaluationCellFontSize] andHeight:200];
        CGFloat levelTextHeight = [LGStringSizeUtil getHeightForText:self.levelText withFont:[UIFont systemFontOfSize:kLGEvaluationCellFontSize] andWidth:levelTextWidth];
        UIImage *evaluationImage = [LGAssetUtil getEvaluationImageWithLevel:0];
        CGFloat evaluationLabelWidth = kLGEvaluationCellLabelHorizontalMargin * 2 + evaluationImage.size.width + levelTextWidth + kLGEvaluationCellLabelHorizontalSpacing;
        CGFloat evaluationLabelHeight = kLGEvaluationCellLabelVerticalMargin * 2 + evaluationImage.size.height;
        self.evaluationLabelFrame = CGRectMake(cellWidth/2 - evaluationLabelWidth/2, kLGEvaluationCellVerticalSpacing, evaluationLabelWidth, evaluationLabelHeight);
        
        self.evaluationImageFrame = CGRectMake(kLGEvaluationCellLabelHorizontalMargin, kLGEvaluationCellLabelVerticalMargin, evaluationImage.size.width, evaluationImage.size.height);
        self.evaluationTextLabelFrame = CGRectMake(self.evaluationImageFrame.origin.x + self.evaluationImageFrame.size.width + kLGEvaluationCellLabelHorizontalSpacing, self.evaluationLabelFrame.size.height/2 - levelTextHeight/2, levelTextWidth, levelTextHeight);
        
        //评价的评论 label frame
        CGFloat commentTextWidth = cellWidth - kLGEvaluationCommentHorizontalSpacing * 2;
        CGFloat commentTextHeight = [LGStringSizeUtil getHeightForText:comment withFont:[UIFont systemFontOfSize:kLGEvaluationCellFontSize] andWidth:commentTextWidth];
        self.commentLabelFrame = comment.length > 0 ? CGRectMake(kLGEvaluationCommentHorizontalSpacing, self.evaluationLabelFrame.origin.y + self.evaluationLabelFrame.size.height + kLGEvaluationCellVerticalSpacing, commentTextWidth, commentTextHeight) : CGRectMake(0, 0, 0, 0);
        
        if (self.commentLabelFrame.size.height > 0) {
            self.cellHeight = self.commentLabelFrame.origin.y + self.commentLabelFrame.size.height + kLGEvaluationCellVerticalSpacing;
        } else {
            self.cellHeight = self.evaluationLabelFrame.origin.y + self.evaluationLabelFrame.size.height + kLGEvaluationCellVerticalSpacing;
        }
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
    return [[LGEvaluationResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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
    //评价的 label frame
    CGFloat levelTextWidth = [LGStringSizeUtil getWidthForText:self.levelText withFont:[UIFont systemFontOfSize:kLGEvaluationCellFontSize] andHeight:200];
    CGFloat levelTextHeight = [LGStringSizeUtil getHeightForText:self.levelText withFont:[UIFont systemFontOfSize:kLGEvaluationCellFontSize] andWidth:levelTextWidth];
    UIImage *evaluationImage = [LGAssetUtil getEvaluationImageWithLevel:0];
    CGFloat evaluationLabelWidth = kLGEvaluationCellLabelHorizontalMargin * 2 + evaluationImage.size.width + levelTextWidth + kLGEvaluationCellLabelHorizontalSpacing;
    CGFloat evaluationLabelHeight = kLGEvaluationCellLabelVerticalMargin * 2 + evaluationImage.size.height;
    self.evaluationLabelFrame = CGRectMake(cellWidth/2 - evaluationLabelWidth/2, kLGEvaluationCellVerticalSpacing, evaluationLabelWidth, evaluationLabelHeight);
    
    self.evaluationImageFrame = CGRectMake(kLGEvaluationCellLabelHorizontalMargin, kLGEvaluationCellLabelVerticalMargin, evaluationImage.size.width, evaluationImage.size.height);
    self.evaluationTextLabelFrame = CGRectMake(self.evaluationImageFrame.origin.x + self.evaluationImageFrame.size.width + kLGEvaluationCellLabelHorizontalSpacing, self.evaluationLabelFrame.size.height/2 - levelTextHeight/2, levelTextWidth, levelTextHeight);
    
    //评价的评论 label frame
    CGFloat commentTextWidth = cellWidth - kLGEvaluationCommentHorizontalSpacing * 2;
    CGFloat commentTextHeight = [LGStringSizeUtil getHeightForText:self.comment withFont:[UIFont systemFontOfSize:kLGEvaluationCellFontSize] andWidth:commentTextWidth];
    self.commentLabelFrame = self.comment.length > 0 ? CGRectMake(kLGEvaluationCommentHorizontalSpacing, self.evaluationLabelFrame.origin.y + self.evaluationLabelFrame.size.height + kLGEvaluationCellVerticalSpacing, commentTextWidth, commentTextHeight) : CGRectMake(0, 0, 0, 0);
    
    if (self.commentLabelFrame.size.height > 0) {
        self.cellHeight = self.commentLabelFrame.origin.y + self.commentLabelFrame.size.height + kLGEvaluationCellVerticalSpacing;
    } else {
        self.cellHeight = self.evaluationLabelFrame.origin.y + self.evaluationLabelFrame.size.height + kLGEvaluationCellVerticalSpacing;
    }
}



@end
