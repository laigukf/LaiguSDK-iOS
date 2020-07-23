//
//  LGChatViewTableDataSource.h
//  LaiGuSDK
//
//  Created by ijinmao on 15/10/28.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGChatViewService.h"
#import <UIKit/UIKit.h>
#import "LGChatBaseCell.h"

/**
 * @brief 客服聊天界面中的UITableView的datasource
 */
@interface LGChatViewTableDataSource : NSObject <UITableViewDataSource>

//- (instancetype)initWithTableView:(UITableView *)tableView  chatViewService:(LGChatViewService *)chatService;
- (instancetype)initWithChatViewService:(LGChatViewService *)chatService;
/**
 *  ChatCell的代理
 */
@property (nonatomic, weak) id<LGChatCellDelegate> chatCellDelegate;

@end
