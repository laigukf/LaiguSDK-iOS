//
//  LGTicket.h
//  LaiGuSDK
//
//  Created by ian luo on 16/8/2.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import <LaiGuSDK/LaiguSDK.h>

@interface LGTickerClientInfo : LGModel

@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *weixin;
@property (nonatomic, copy) NSString *qq;

@end

@interface LGTicket : LGModel

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSNumber *enterpriseId;
@property (nonatomic, strong) NSNumber *conversationId;
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, copy) NSString *trackId;
@property (nonatomic, copy) NSString *assigneeId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSNumber *categoryId;
@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, copy) NSString *cc;
@property (nonatomic, strong) LGTickerClientInfo *clientInfo;
@property (nonatomic, strong) NSDate *createAt;
@property (nonatomic, strong) NSDate *updateAt;

@end

@interface LGTicketReply : LGModel

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSNumber *enterpriseId;
@property (nonatomic, strong) NSNumber *ticketId;
@property (nonatomic, copy) NSString *agentId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, strong) NSDate *createAt;
@property (nonatomic, strong) NSDate *updateAt;

@end

@interface LGTicketCategory : LGModel

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSNumber *enterpriseId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *createAt;
@property (nonatomic, strong) NSDate *updateAt;

@end
