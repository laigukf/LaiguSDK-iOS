//
//  LGMessageDateCell.m
//  LaiGuSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGMessageDateCell.h"
#import "LGMessageDateCellModel.h"
#import "LGDateFormatterUtil.h"

static CGFloat const kLGMessageDateLabelFontSize = 12.0;

@implementation LGMessageDateCell {
    UILabel *dateLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化时间label
        dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.font = [UIFont systemFontOfSize:kLGMessageDateLabelFontSize];
        dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:dateLabel];
    }
    return self;
}


#pragma LGChatCellProtocol
- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    if (![model isKindOfClass:[LGMessageDateCellModel class]]) {
        NSAssert(NO, @"传给LGMessageDateCell的Model类型不正确");
        return ;
    }
    LGMessageDateCellModel *cellModel = (LGMessageDateCellModel *)model;
    
    //刷新时间label
    dateLabel.text = [[LGDateFormatterUtil sharedFormatter] laiguStyleDateForDate:cellModel.date];
    dateLabel.frame = cellModel.dateLabelFrame;
}



@end
