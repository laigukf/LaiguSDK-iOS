//
//  LGEventMessageCell.m
//  LaiGuSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGEventMessageCell.h"
#import "LGEventCellModel.h"
#import "LGChatViewConfig.h"

static CGFloat const kLGMessageEventLabelFontSize = 14.0;

@implementation LGEventMessageCell {
    UILabel *eventLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化事件label
        eventLabel = [[UILabel alloc] init];
        eventLabel.textColor = [LGChatViewConfig sharedConfig].eventTextColor;
        eventLabel.textAlignment = NSTextAlignmentCenter;
        eventLabel.font = [UIFont systemFontOfSize:kLGMessageEventLabelFontSize];
        [self.contentView addSubview:eventLabel];
    }
    return self;
}

#pragma LGChatCellProtocol
- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    if (![model isKindOfClass:[LGEventCellModel class]]) {
        NSAssert(NO, @"传给LGEventMessageCell的Model类型不正确");
        return ;
    }
    LGEventCellModel *cellModel = (LGEventCellModel *)model;
    
    //刷新时间label
    eventLabel.text = cellModel.eventContent;
    eventLabel.frame = cellModel.eventLabelFrame;
}

@end
