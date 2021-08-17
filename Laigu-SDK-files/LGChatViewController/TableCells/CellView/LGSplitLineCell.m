//
//  LGSplitLineCell.m
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/21.
//  Copyright © 2020 ijinmao. All rights reserved.
//

#import "LGSplitLineCell.h"
#import <Foundation/Foundation.h>
#import "LGSplitLineCellModel.h"
#import "LGDateFormatterUtil.h"
#import "UIColor+LGHex.h"

@implementation LGSplitLineCell {
    UILabel *_lable;
    UIView *_leftLine;
    UIView *_rightLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *lable = [[UILabel alloc] init];
        lable.font = [UIFont boldSystemFontOfSize:14];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = [UIColor colorWithRed:242/255 green:242/255 blue:247/255 alpha:0.2];
        _lable = lable;
        [self.contentView addSubview:_lable];
        
        UIView *leftLine = [UIView new];
        leftLine.backgroundColor = [UIColor colorWithRed:242/255 green:242/255 blue:247/255 alpha:0.2];
        _leftLine = leftLine;
        [self.contentView addSubview:_leftLine];
        
        UIView *rightLine = [UIView new];
        rightLine.backgroundColor = [UIColor colorWithRed:242/255 green:242/255 blue:247/255 alpha:0.2];
        _rightLine = rightLine;
        [self.contentView addSubview:_rightLine];
        
    }
    return self;
}

#pragma LGChatCellProtocol
- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    if (![model isKindOfClass:[LGSplitLineCellModel class]]) {
        NSAssert(NO, @"传给LGEventMessageCell的Model类型不正确");
        return ;
    }
    LGSplitLineCellModel *cellModel = (LGSplitLineCellModel *)model;
    _lable.frame = cellModel.labelFrame;
    _leftLine.frame = cellModel.leftLineFrame;
    _rightLine.frame = cellModel.rightLineFrame;
    _lable.text = [[LGDateFormatterUtil sharedFormatter] laiguSplitLineDateForDate:cellModel.getCellDate];

}

@end


