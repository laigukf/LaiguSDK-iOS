//
//  LGEvaluationCell.h
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 16/1/19.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGEvaluationCell : UITableViewCell

/**
 *  设定评价的等级
 *
 *  @param level 等级
 */
- (void)setLevel:(NSInteger)level;

/**
 *  计算该 cell 的高度
 */
+ (CGFloat)getCellHeight;

/**
 *  隐藏 cell 的底线
 */
- (void)hideBottomLine;

@end
