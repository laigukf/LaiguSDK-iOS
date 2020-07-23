//
//  LGChatViewTableDataSource.m
//  LaiGuSDK
//
//  Created by ijinmao on 15/10/28.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGChatViewTableDataSource.h"
#import "LGChatBaseCell.h"
#import "LGCellModelProtocol.h"

@interface LGChatViewTableDataSource()

@property (nonatomic, weak) LGChatViewService *chatViewService;

@end

@implementation LGChatViewTableDataSource {
}

- (instancetype)initWithChatViewService:(LGChatViewService *)chatService {
    if (self = [super init]) {
        self.chatViewService = chatService;
    }
    return self;
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.chatViewService.cellModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<LGCellModelProtocol> cellModel = [self.chatViewService.cellModels objectAtIndex:indexPath.row];
    NSString *cellModelName = NSStringFromClass([cellModel class]);
//    NSString *messageId = [cellModel getCellMessageId]?:NSStringFromClass([cellModel class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellModelName];
    if (!cell){
        cell = [cellModel getCellWithReuseIdentifier:cellModelName];
        LGChatBaseCell *chatCell = (LGChatBaseCell*)cell;
        chatCell.chatCellDelegate = self.chatCellDelegate;
    }
    if (![cell isKindOfClass:[LGChatBaseCell class]]) {
        NSAssert(NO, @"ChatTableDataSource的cellForRow中，没有返回正确的cell类型");
        return cell;
    }
    //xlp 富文本时返回的信息是  cell类型是  LGBotWebViewBubbleAnswerCell  model类型是 LGBotWebViewBubbleAnswerCellModel
    [(LGChatBaseCell*)cell updateCellWithCellModel:cellModel];
    return cell;
}




@end
