//
//  LGMessageDateCellModel.m
//  LaiGuSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGMessageDateCellModel.h"
#import "LGChatBaseCell.h"
#import "LGMessageDateCell.h"
#import "LGDateFormatterUtil.h"
#import "LGStringSizeUtil.h"


@interface LGMessageDateCellModel()
/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 消息的中文时间
 */
@property (nonatomic, readwrite, copy) NSString *dateString;

/**
 * @brief 消息气泡button的frame
 */
@property (nonatomic, readwrite, assign) CGRect dateLabelFrame;

@end

@implementation LGMessageDateCellModel

#pragma initialize
/**
 *  根据时间来生成cell model
 */
- (LGMessageDateCellModel *)initCellModelWithDate:(NSDate *)date cellWidth:(CGFloat)cellWidth{
    if (self = [super init]) {
        self.date = date;
        self.dateString = [[LGDateFormatterUtil sharedFormatter] laiguStyleDateForDate:date];
        //时间文字size
        CGFloat dateLabelWidth = cellWidth - kLGChatMessageDateLabelToEdgeSpacing * 2;
        CGFloat dateLabelHeight = [LGStringSizeUtil getHeightForText:self.dateString withFont:[UIFont systemFontOfSize:kLGChatMessageDateLabelFontSize] andWidth:dateLabelWidth];
        self.dateLabelFrame = CGRectMake(cellWidth/2-dateLabelWidth/2, kLGChatMessageDateCellHeight/2-dateLabelHeight/2+kLGChatMessageDateLabelVerticalOffset, dateLabelWidth, dateLabelHeight);
        
        self.cellHeight = kLGChatMessageDateCellHeight;
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
    return [[LGMessageDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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
    self.cellWidth = cellWidth;
    self.dateLabelFrame = CGRectMake(cellWidth/2-self.dateLabelFrame.size.width/2, kLGChatMessageDateCellHeight/2-self.dateLabelFrame.size.height/2+kLGChatMessageDateLabelVerticalOffset, self.dateLabelFrame.size.width, self.dateLabelFrame.size.height);
}


@end
