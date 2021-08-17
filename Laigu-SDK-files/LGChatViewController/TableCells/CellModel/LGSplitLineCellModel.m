//
//  LGSplitLineCellModel.m
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/21.
//  Copyright © 2020 ijinmao. All rights reserved.
//

#import "LGSplitLineCellModel.h"
#import "LGSplitLineCell.h"

static CGFloat const kLGSplitLineCellSpacing = 20.0;
static CGFloat const kLGSplitLineCellHeight = 40.0;
static CGFloat const kLGSplitLineCellLableHeight = 20.0;
static CGFloat const kLGSplitLineCellLableWidth = 150.0;
@interface LGSplitLineCellModel()

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;
@property (nonatomic, readwrite, assign) CGRect labelFrame;
@property (nonatomic, readwrite, assign) CGRect leftLineFrame;
@property (nonatomic, readwrite, assign) CGRect rightLineFrame;
@property (nonatomic, readwrite, copy) NSDate *currentDate;

@end

@implementation LGSplitLineCellModel

- (LGSplitLineCellModel *)initCellModelWithCellWidth:(CGFloat)cellWidth withConversionDate:(NSDate *)date {
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.currentDate = date;

        self.labelFrame = CGRectMake(cellWidth/2.0 - kLGSplitLineCellLableWidth/2.0, (kLGSplitLineCellHeight - kLGSplitLineCellLableHeight)/2.0 - 3, kLGSplitLineCellLableWidth, kLGSplitLineCellLableHeight);
        self.leftLineFrame = CGRectMake(kLGSplitLineCellSpacing, kLGSplitLineCellHeight/2.0, CGRectGetMinX(self.labelFrame) - kLGSplitLineCellSpacing, 0.5);
        self.rightLineFrame = CGRectMake(CGRectGetMaxX(self.labelFrame), CGRectGetMinY(self.leftLineFrame), cellWidth - kLGSplitLineCellSpacing - CGRectGetMaxX(self.labelFrame), 0.5);
    }
    return self;
}


#pragma LGCellModelProtocol
- (NSDate *)getCellDate {
    return self.currentDate;
}

- (CGFloat)getCellHeight {
    return kLGSplitLineCellHeight;
}

- (NSString *)getCellMessageId {
    return @"";
}

- (NSString *)getMessageConversionId {
    return @"";
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGSplitLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];;
}

- (BOOL)isServiceRelatedCell {
    return false;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    
    self.labelFrame = CGRectMake(cellWidth/2.0 - kLGSplitLineCellLableWidth/2.0, (kLGSplitLineCellHeight - kLGSplitLineCellLableHeight)/2.0, kLGSplitLineCellLableWidth, kLGSplitLineCellLableHeight);
    self.leftLineFrame = CGRectMake(kLGSplitLineCellSpacing, kLGSplitLineCellHeight/2.0, CGRectGetMinX(self.labelFrame) - kLGSplitLineCellSpacing, 1);
    self.rightLineFrame = CGRectMake(CGRectGetMaxX(self.labelFrame), CGRectGetMinY(self.leftLineFrame), cellWidth - kLGSplitLineCellSpacing - CGRectGetMaxX(self.labelFrame), 1);
}

@end
