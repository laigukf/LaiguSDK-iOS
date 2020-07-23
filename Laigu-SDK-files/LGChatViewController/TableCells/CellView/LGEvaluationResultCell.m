//
//  LGEvaluationResultCell.m
//  LGChatViewControllerDemo
//
//  Created by ijinmao on 16/3/1.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "LGEvaluationResultCell.h"
#import "LGEvaluationResultCellModel.h"
#import "LGAssetUtil.h"
#import "LGImageUtil.h"

@implementation LGEvaluationResultCell {
    UILabel *evaluationLabel;
    UILabel *commentLabel;
    UIImageView *evaluationImageView;
    UILabel *evaluationTextLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化
        evaluationLabel = [[UILabel alloc] init];
        evaluationTextLabel = [[UILabel alloc] init];
        evaluationTextLabel.font = [UIFont systemFontOfSize:kLGEvaluationCellFontSize];
        evaluationTextLabel.textColor = [UIColor whiteColor];
        evaluationImageView = [[UIImageView alloc] initWithImage:[LGAssetUtil getEvaluationImageWithLevel:0]];
        commentLabel = [[UILabel alloc] init];
        commentLabel.font = [UIFont systemFontOfSize:kLGEvaluationCellFontSize];
        commentLabel.textColor = [UIColor lightGrayColor];
        commentLabel.textAlignment = NSTextAlignmentCenter;
        commentLabel.numberOfLines = 0;
        [evaluationLabel addSubview:evaluationImageView];
        [evaluationLabel addSubview:evaluationTextLabel];
        [self.contentView addSubview:evaluationLabel];
        [self.contentView addSubview:commentLabel];
    }
    return self;
}

#pragma LGChatCellProtocol
- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    if (![model isKindOfClass:[LGEvaluationResultCellModel class]]) {
        NSAssert(NO, @"传给LGTipsCell的Model类型不正确");
        return ;
    }
    
    LGEvaluationResultCellModel *cellModel = (LGEvaluationResultCellModel *)model;
    
    evaluationLabel.backgroundColor = cellModel.evaluationLabelColor;
    evaluationLabel.frame = cellModel.evaluationLabelFrame;
    evaluationLabel.layer.cornerRadius = evaluationLabel.frame.size.height / 2;
    evaluationLabel.layer.masksToBounds = true;
    
    evaluationImageView.frame = cellModel.evaluationImageFrame;
    NSInteger level = 2;
    switch (cellModel.evaluationType) {
        case LGEvaluationTypePositive:
            level = 2;
            break;
        case LGEvaluationTypeModerate:
            level = 1;
            break;
        case LGEvaluationTypeNegative:
            level = 0;
            break;
        default:
            break;
    }
    if (cellModel.evaluationImageFrame.size.height > 0) {
        evaluationImageView.image = [LGImageUtil convertImageColorWithImage:[LGAssetUtil getEvaluationImageWithLevel:level] toColor:[UIColor whiteColor]];
        evaluationImageView.hidden = false;
    } else {
        evaluationImageView.hidden = true;
    }
    evaluationTextLabel.frame = cellModel.evaluationTextLabelFrame;
    evaluationTextLabel.text = cellModel.levelText;
    
    commentLabel.frame = cellModel.commentLabelFrame;
    commentLabel.text = cellModel.comment;
}

@end
