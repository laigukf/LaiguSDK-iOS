//
//  LGChatTableView.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/30.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGChatViewService.h"

@protocol LGChatTableViewDelegate <NSObject>

/** 点击 */
- (void)didTapChatTableView:(UITableView *)tableView;

@end

@interface LGChatTableView : UITableView


@property (nonatomic, weak) id<LGChatTableViewDelegate> chatTableViewDelegate;


/** 更新indexPath的cell */
- (void)updateTableViewAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollToCellIndex:(NSInteger)index;

- (BOOL)isTableViewScrolledToBottom;

@end
