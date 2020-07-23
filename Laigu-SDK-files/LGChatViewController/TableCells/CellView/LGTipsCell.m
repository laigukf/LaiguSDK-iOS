//
//  LGTipsCell.m
//  LaiGuSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGTipsCell.h"
#import "LGTipsCellModel.h"
#import "LGBundleUtil.h"

@implementation LGTipsCell {
    UILabel *tipsLabel;
    CALayer *topLineLayer;
    CALayer *bottomLineLayer;
    UITapGestureRecognizer *tapReconizer;
    LGTipType tipType;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化提示label
        tipsLabel = [[UILabel alloc] init];
        tipsLabel.textColor = [UIColor grayColor];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.font = [UIFont systemFontOfSize:kLGMessageTipsFontSize];
        tipsLabel.backgroundColor = [UIColor clearColor];
        tipsLabel.numberOfLines = 0;
        [self.contentView addSubview:tipsLabel];
        //画上下两条线
        topLineLayer = [self gradientLine];
        [self.contentView.layer addSublayer:topLineLayer];
        bottomLineLayer = [self gradientLine];
        [self.contentView.layer addSublayer:bottomLineLayer];
    }
    return self;
}

#pragma LGChatCellProtocol
- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    if (![model isKindOfClass:[LGTipsCellModel class]]) {
        NSAssert(NO, @"传给LGTipsCell的Model类型不正确");
        return ;
    }
    
    LGTipsCellModel *cellModel = (LGTipsCellModel *)model;
    
    tipType = cellModel.tipType;
    
    //刷新时间label
    NSMutableAttributedString *tipsString = [[NSMutableAttributedString alloc] initWithString:cellModel.tipText];
    if (cellModel.tipExtraAttributesRange.length + cellModel.tipExtraAttributesRange.location <= tipsString.length) {
        
        [tipsString addAttributes:cellModel.tipExtraAttributes range:cellModel.tipExtraAttributesRange];
    }
    tipsLabel.attributedText = tipsString;
    tipsLabel.frame = cellModel.tipLabelFrame;
    
    //刷新上下两条线
    if (cellModel.enableLinesDisplay) {
        [self.contentView.layer addSublayer:topLineLayer];
        [self.contentView.layer addSublayer:bottomLineLayer];
    } else {
        [topLineLayer removeFromSuperlayer];
        [bottomLineLayer removeFromSuperlayer];
    }
    topLineLayer.frame = cellModel.topLineFrame;
    bottomLineLayer.frame = cellModel.bottomLineFrame;
    
    // 判断是否该 tip 是提示留言的 tip，若是提示留言 tip，则增加点击事件
    if (!tapReconizer) {
        tapReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTipCell:)];
        self.contentView.userInteractionEnabled = true;
        [self.contentView addGestureRecognizer:tapReconizer];
    }
}

- (CAGradientLayer*)gradientLine {
    CAGradientLayer* line = [CAGradientLayer layer];
    line.backgroundColor = [UIColor clearColor].CGColor;
    line.startPoint = CGPointMake(0.1, 0.5);
    line.endPoint = CGPointMake(0.9, 0.5);
    line.colors = @[(id)[UIColor clearColor].CGColor,
                    (id)[UIColor lightGrayColor].CGColor,
                    (id)[UIColor lightGrayColor].CGColor,
                    (id)[UIColor clearColor].CGColor];
    return line;
}

- (void)tapTipCell:(id)sender {
    if ([tipsLabel.text isEqualToString:[LGBundleUtil localizedStringForKey:@"reply_tip_text"]]) {
        if ([self.chatCellDelegate respondsToSelector:@selector(didTapReplyBtn)]) {
            [self.chatCellDelegate didTapReplyBtn];
        }
    }
    NSArray *botRedirectArray = @[[LGBundleUtil localizedStringForKey:@"bot_redirect_tip_text"], [LGBundleUtil localizedStringForKey:@"bot_manual_redirect_tip_text"]];
    if ([botRedirectArray containsObject:tipsLabel.text]) {
        if ([self.chatCellDelegate respondsToSelector:@selector(didTapBotRedirectBtn)]) {
            [self.chatCellDelegate didTapBotRedirectBtn];
        }
    }
    if (tipType == LGTipTypeWaitingInQueue) {
        if ([self.chatCellDelegate respondsToSelector:@selector(didTapReplyBtn)]) {
            [self.chatCellDelegate didTapReplyBtn];
        }
    }
}



@end
