//
//  LGServiceToViewInterface.m
//  LGChatViewControllerDemo
//
//  Created by ijinmao on 15/11/5.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "LGServiceToViewInterface.h"
#import <LaiGuSDK/LaiguSDK.h>
#import "LGBundleUtil.h"
#import "LGChatFileUtil.h"
#import "NSArray+LGFunctional.h"
#import "LGBotMessageFactory.h"
#import "LGMessageFactoryHelper.h"
#import "LGVisialMessageFactory.h"
#import "LGEventMessageFactory.h"

#pragma 该文件的作用是:开源聊天界面调用来鼓 SDK 接口的中间层,目的是剥离开源界面中的来鼓业务逻辑.这样就能让该聊天界面用于非来鼓项目中,开发者只需要实现 'LGServiceToViewInterface'中的方法,即可将自己项目的业务逻辑和该聊天界面对接.

@interface LGServiceToViewInterface()<LGManagerDelegate>

@end

@implementation LGServiceToViewInterface

+ (void)getServerHistoryMessagesWithMsgDate:(NSDate *)msgDate
                             messagesNumber:(NSInteger)messagesNumber
                            successDelegate:(id<LGServiceToViewInterfaceDelegate>)successDelegate
                              errorDelegate:(id<LGServiceToViewInterfaceErrorDelegate>)errorDelegate
{
    //将msgDate修改成GMT时区
    [LGManager getServerHistoryMessagesWithUTCMsgDate:msgDate messagesNumber:messagesNumber success:^(NSArray<LGMessage *> *messagesArray) {
        NSArray *toMessages = [LGServiceToViewInterface convertToChatViewMessageWithLGMessages:messagesArray];
        if (successDelegate) {
            if ([successDelegate respondsToSelector:@selector(didReceiveHistoryMessages:)]) {
                [successDelegate didReceiveHistoryMessages:toMessages];
            }
        }
    } failure:^(NSError *error) {
        if (errorDelegate) {
            if ([errorDelegate respondsToSelector:@selector(getLoadHistoryMessageError)]) {
                [errorDelegate getLoadHistoryMessageError];
            }
        }
    }];
}

+ (void)getDatabaseHistoryMessagesWithMsgDate:(NSDate *)msgDate
                               messagesNumber:(NSInteger)messagesNumber
                                     delegate:(id<LGServiceToViewInterfaceDelegate>)delegate
{
    [LGManager getDatabaseHistoryMessagesWithMsgDate:msgDate messagesNumber:messagesNumber result:^(NSArray<LGMessage *> *messagesArray) {
        NSArray *toMessages = [LGServiceToViewInterface convertToChatViewMessageWithLGMessages:messagesArray];
        if (delegate) {
            if ([delegate respondsToSelector:@selector(didReceiveHistoryMessages:)]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [delegate didReceiveHistoryMessages:toMessages];
                });
            }
        }
    }];
}

+ (NSArray *)convertToChatViewMessageWithLGMessages:(NSArray *)messagesArray {
    //将LGMessage转换成UI能用的Message类型
    NSMutableArray *toMessages = [[NSMutableArray alloc] init];
    for (LGMessage *fromMessage in messagesArray) {
        LGBaseMessage *toMessage = [[LGMessageFactoryHelper factoryWithMessageAction:fromMessage.action contentType:fromMessage.contentType fromType:fromMessage.fromType] createMessage:fromMessage];
        if (toMessage) {
            [toMessages addObject:toMessage];
        }
    }
    
    return toMessages;
}


+ (void)sendTextMessageWithContent:(NSString *)content
                         messageId:(NSString *)localMessageId
                          delegate:(id<LGServiceToViewInterfaceDelegate>)delegate;
{
    [LGManager sendTextMessageWithContent:content completion:^(LGMessage *sendedMessage, NSError *error) {
        [self didSendMessage:sendedMessage localMessageId:localMessageId delegate:delegate];
    }];
}

+ (void)sendImageMessageWithImage:(UIImage *)image
                        messageId:(NSString *)localMessageId
                         delegate:(id<LGServiceToViewInterfaceDelegate>)delegate;
{
    [LGManager sendImageMessageWithImage:image completion:^(LGMessage *sendedMessage, NSError *error) {
        [self didSendMessage:sendedMessage localMessageId:localMessageId delegate:delegate];
    }];
}

+ (void)sendAudioMessage:(NSData *)audio
               messageId:(NSString *)localMessageId
                delegate:(id<LGServiceToViewInterfaceDelegate>)delegate;
{
    [LGManager sendAudioMessage:audio completion:^(LGMessage *sendedMessage, NSError *error) {
        [self didSendMessage:sendedMessage localMessageId:localMessageId delegate:delegate];
    }];
}

+ (void)sendClientInputtingWithContent:(NSString *)content
{
    [LGManager sendClientInputtingWithContent:content];
}

+ (void)didSendMessage:(LGMessage *)sendedMessage
        localMessageId:(NSString *)localMessageId
              delegate:(id<LGServiceToViewInterfaceDelegate>)delegate
{
    if (delegate) {
        if ([delegate respondsToSelector:@selector(didSendMessageWithNewMessageId:oldMessageId:newMessageDate:replacedContent:sendStatus:)]) {
            LGChatMessageSendStatus sendStatus = LGChatMessageSendStatusSuccess;
            if (sendedMessage.sendStatus == LGMessageSendStatusFailed) {
                sendStatus = LGChatMessageSendStatusFailure;
            } else if (sendedMessage.sendStatus == LGMessageSendStatusSending) {
                sendStatus = LGChatMessageSendStatusSending;
            }
            [delegate didSendMessageWithNewMessageId:sendedMessage.messageId oldMessageId:localMessageId newMessageDate:sendedMessage.createdOn replacedContent:sendedMessage.isSensitive ? sendedMessage.content : nil  sendStatus:sendStatus];
        }
    }
}

+ (void)didSendFailedWithMessage:(LGMessage *)failedMessage
                  localMessageId:(NSString *)localMessageId
                           error:(NSError *)error
                        delegate:(id<LGServiceToViewInterfaceDelegate>)delegate
{
    NSLog(@"来鼓SDK: 发送text消息失败\nerror = %@", error);
    if (delegate) {
        if ([delegate respondsToSelector:@selector(didSendMessageWithNewMessageId:oldMessageId:newMessageDate:replacedContent:sendStatus:)]) {
            [delegate didSendMessageWithNewMessageId:localMessageId oldMessageId:localMessageId newMessageDate:nil replacedContent:nil sendStatus:LGChatMessageSendStatusFailure];
        }
    }
}

+ (void)setClientOffline
{
    [LGManager setClientOffline];
}

//+ (void)didTapMessageWithMessageId:(NSString *)messageId {
////    [LGManager updateMessage:messageId toReadStatus:YES];
//}

+ (NSString *)getCurrentAgentName {
    NSString *agentName = [LGManager getCurrentAgent].nickname;
    return agentName.length == 0 ? @"" : agentName;
}

+ (LGAgent *)getCurrentAgent {
    return [LGManager getCurrentAgent];
}

+ (LGChatAgentStatus)getCurrentAgentStatus {
    LGAgent *agent = [LGManager getCurrentAgent];
    if (!agent.isOnline) {
        return LGChatAgentStatusOffLine;
    }
    switch (agent.status) {
        case LGAgentStatusHide:
            return LGChatAgentStatusOffDuty;
            break;
        case LGAgentStatusOnline:
            return LGChatAgentStatusOnDuty;
            break;
        default:
            return LGChatAgentStatusOnDuty;
            break;
    }
    
}

+ (BOOL)isThereAgent {
    return [LGManager getCurrentAgent].agentId.length > 0;
}

+ (void)downloadMediaWithUrlString:(NSString *)urlString
                          progress:(void (^)(float progress))progressBlock
                        completion:(void (^)(NSData *mediaData, NSError *error))completion
{
    [LGManager downloadMediaWithUrlString:urlString progress:^(float progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } completion:^(NSData *mediaData, NSError *error) {
        if (completion) {
            completion(mediaData, error);
        }
    }];
}

+ (void)removeMessageInDatabaseWithId:(NSString *)messageId
                           completion:(void (^)(BOOL, NSError *))completion
{
    [LGManager removeMessageInDatabaseWithId:messageId completion:completion];
}

+ (NSDictionary *)getCurrentClientInfo {
    return [LGManager getCurrentClientInfo];
}

+ (void)uploadClientAvatar:(UIImage *)avatarImage
                completion:(void (^)(NSString *avatarUrl, NSError *error))completion
{
    [LGManager setClientAvatar:avatarImage completion:^(NSString *avatarUrl, NSError *error) {
        [LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage = avatarImage;
        [[NSNotificationCenter defaultCenter] postNotificationName:LGChatTableViewShouldRefresh object:avatarImage];
        if (completion) {
            completion(avatarUrl, error);
        }
    }];
}

+ (void)getEnterpriseConfigInfoWithCache:(BOOL)isLoadCache complete:(void(^)(LGEnterprise *, NSError *))action {
    [LGManager getEnterpriseConfigDataWithCache:isLoadCache complete:action];
}

#pragma 实例方法
- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setClientOnlineWithCustomizedId:(NSString *)customizedId
                                success:(void (^)(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error))success
                 receiveMessageDelegate:(id<LGServiceToViewInterfaceDelegate>)receiveMessageDelegate
{
    self.serviceToViewDelegate = receiveMessageDelegate;
    [LGManager setClientOnlineWithCustomizedId:customizedId success:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
        NSArray *toMessages = [LGServiceToViewInterface convertToChatViewMessageWithLGMessages:messages];
        if (result == LGClientOnlineResultSuccess) {
            NSString *agentType = [agent convertPrivilegeToString];
            success(true, agent.nickname, agentType, toMessages, nil);
        } else if(result == LGClientOnlineResultNotScheduledAgent) {
            success(false, @"", @"", toMessages,nil);
        }
    } failure:^(NSError *error) {
        success(false, @"", @"", nil, error);
    } receiveMessageDelegate:self];
}

- (void)setClientOnlineWithClientId:(NSString *)clientId
                            success:(void (^)(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error))success
             receiveMessageDelegate:(id<LGServiceToViewInterfaceDelegate>)receiveMessageDelegate
{
    self.serviceToViewDelegate = receiveMessageDelegate;

    [LGManager setClientOnlineWithClientId:clientId success:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
        if (result == LGClientOnlineResultSuccess) {
            NSArray *toMessages = [LGServiceToViewInterface convertToChatViewMessageWithLGMessages:messages];
            NSString *agentType = [agent convertPrivilegeToString];
            success(true, agent.nickname, agentType, toMessages, nil);
        } else if((result == LGClientOnlineResultNotScheduledAgent) || (result == LGClientOnlineResultBlacklisted))  {
            success(false, @"", @"", nil, nil);
        }
    } failure:^(NSError *error) {
        success(false, @"初始化失败，请重新打开", @"", nil, error);
    } receiveMessageDelegate:self];
}

+ (void)setScheduledAgentWithAgentId:(NSString *)agentId
                        agentGroupId:(NSString *)agentGroupId
                        scheduleRule:(LGChatScheduleRules)scheduleRule
{
    LGScheduleRules rule = 0;
    switch (scheduleRule) {
        case LGChatScheduleRulesRedirectNone:
            rule = LGScheduleRulesRedirectNone;
            break;
        case LGChatScheduleRulesRedirectGroup:
            rule = LGScheduleRulesRedirectGroup;
            break;
        case LGChatScheduleRulesRedirectEnterprise:
            rule = LGScheduleRulesRedirectEnterprise;
            break;
        default:
            break;
    }
    [LGManager setScheduledAgentWithAgentId:agentId agentGroupId:agentGroupId scheduleRule:rule];
}

+ (void)setNotScheduledAgentWithAgentId:(NSString *)agentId {
    [LGManager setNotScheduledAgentWithAgentId:agentId];
}

+ (void)deleteScheduledAgent {
    [LGChatViewConfig sharedConfig].scheduledAgentId = nil;
    [LGChatViewConfig sharedConfig].scheduledGroupId = nil;
    [LGManager deleteScheduledAgent];
}

+ (void)setEvaluationLevel:(NSInteger)level
                   comment:(NSString *)comment
{
    LGConversationEvaluation evaluation = LGConversationEvaluationPositive;
    switch (level) {
        case 0:
            evaluation = LGConversationEvaluationNegative;
            break;
        case 1:
            evaluation = LGConversationEvaluationModerate;
            break;
        case 2:
            evaluation = LGConversationEvaluationPositive;
            break;
        default:
            break;
    }
    [LGManager evaluateCurrentConversationWithEvaluation:evaluation comment:comment completion:^(BOOL success, NSError *error) {
    }];
}

+ (void)setClientInfoWithDictionary:(NSDictionary *)clientInfo
                         completion:(void (^)(BOOL success, NSError *error))completion
{
    if (!clientInfo) {
        NSLog(@"来鼓 SDK：上传自定义信息不能为空。");
        completion(false, nil);
    }
    
    if ([LGChatViewConfig sharedConfig].updateClientInfoUseOverride) {
        [LGManager updateClientInfo:clientInfo completion:completion];
    } else {
        [LGManager setClientInfo:clientInfo completion:completion];
    }
}

+ (void)updateClientInfoWithDictionary:(NSDictionary *)clientInfo
                            completion:(void (^)(BOOL success, NSError *error))completion {
    if (!clientInfo) {
        NSLog(@"来鼓 SDK：上传自定义信息不能为空。");
        completion(false, nil);
    }
    [LGManager updateClientInfo:clientInfo completion:^(BOOL success, NSError *error) {
        completion(success, error);
    }];
}

+ (void)setCurrentInputtingText:(NSString *)inputtingText {
    [LGManager setCurrentInputtingText:inputtingText];
}

+ (NSString *)getPreviousInputtingText {
    return [LGManager getPreviousInputtingText];
}

+ (void)getUnreadMessagesWithCompletion:(void (^)(NSArray *messages, NSError *error))completion {
    return [LGManager getUnreadMessagesWithCompletion:completion];
}

+ (NSArray *)getLocalUnreadMessages {
    return [LGManager getLocalUnreadeMessages];
}

+ (BOOL)isBlacklisted {
    return [LGManager isBlacklisted];
}

+ (void)clearReceivedFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if ([fileManager fileExistsAtPath:DIR_RECEIVED_FILE isDirectory:&isDir]) {
        NSError *error;
        [fileManager removeItemAtPath:DIR_RECEIVED_FILE error:&error];
        if (error) {
            NSLog(@"Fail to clear received files: %@",error.localizedDescription);
        }
    }
}

+ (void)updateMessageWithId:(NSString *)messageId forAccessoryData:(NSDictionary *)accessoryData {
    [LGManager updateMessageWithId:messageId forAccessoryData:accessoryData];
}

+ (void)updateMessageIds:(NSArray *)messageIds toReadStatus:(BOOL)isRead {
    [LGManager updateMessageIds:messageIds toReadStatus:isRead];
}

+ (void)markAllMessagesAsRead {
    [LGManager markAllMessagesAsRead];
}

+ (void)prepareForChat {
    [LGManager didStartChat];
}

+ (void)completeChat {
    [LGManager didEndChat];
}

+ (void)refreshLocalClientWithCustomizedId:(NSString *)customizedId complete:(void(^)(NSString *clientId))action {
    [LGManager refreshLocalClientWithCustomizedId:customizedId complete:action];
}

+ (void)clientDownloadFileWithMessageId:(NSString *)messageId
                          conversatioId:(NSString *)conversationId
                          andCompletion:(void(^)(NSString *url, NSError *error))action {
    [LGManager clientDownloadFileWithMessageId:messageId conversatioId:conversationId andCompletion:action];
}

+ (void)cancelDownloadForUrl:(NSString *)urlString {
    [LGManager cancelDownloadForUrl:urlString];
}

+ (void)evaluateBotMessage:(NSString *)messageId
                  isUseful:(BOOL)isUseful
                completion:(void (^)(BOOL success, NSString *text, NSError *error))completion
{
    [LGManager evaluateBotMessage:messageId isUseful:isUseful completion:completion];
}

#pragma mark - LGManagerDelegate

- (void)didReceiveLGMessages:(NSArray<LGMessage *> *)messages {
    if (!self.serviceToViewDelegate) {
        return;
    }
    
    if ([self.serviceToViewDelegate respondsToSelector:@selector(didReceiveNewMessages:)]) {
        [self.serviceToViewDelegate didReceiveNewMessages:[LGServiceToViewInterface convertToChatViewMessageWithLGMessages:messages]];
    }
}

- (void)didScheduleResult:(LGClientOnlineResult)onLineResult withResultMessages:(NSArray<LGMessage *> *)message{
    if ([self.serviceToViewDelegate respondsToSelector:@selector(didScheduleResult:withResultMessages:)]) {
        [self.serviceToViewDelegate didScheduleResult:onLineResult withResultMessages:message];
    }
}

//强制转人工
- (void)forceRedirectHumanAgentWithSuccess:(void (^)(BOOL completion, NSString *agentName, NSArray *receivedMessages))success
                                   failure:(void (^)(NSError *error))failure
                    receiveMessageDelegate:(id<LGServiceToViewInterfaceDelegate>)receiveMessageDelegate
{
    self.serviceToViewDelegate = receiveMessageDelegate;
    
    [LGManager forceRedirectHumanAgentWithSuccess:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
        NSArray *toMessages = [LGServiceToViewInterface convertToChatViewMessageWithLGMessages:messages];
        if (result == LGClientOnlineResultSuccess) {
            success(true, agent.nickname, toMessages);
        } else if(result == LGClientOnlineResultNotScheduledAgent) {
            success(false, @"", toMessages);
        }
    } failure:^(NSError *error) {
        
    } receiveMessageDelegate:self];
}

/**
 转换 emoji 别名为 Unicode
 */
+ (NSString *)convertToUnicodeWithEmojiAlias:(NSString *)text {
    return [LGManager convertToUnicodeWithEmojiAlias:text];
}

+ (NSString *)getCurrentAgentId {
    return [LGManager getCurrentAgentId];
}

+ (NSString *)getCurrentAgentType {
    return [LGManager getCurrentAgentType];
}

+ (void)getEvaluationPromtTextComplete:(void (^)(NSString *, NSError *))action {
    [LGManager getEvaluationPromtTextComplete:action];
}

+ (void)getIsShowRedirectHumanButtonComplete:(void (^)(BOOL, NSError *))action {
    [LGManager getIsShowRedirectHumanButtonComplete:action];
}

+ (void)getMessageFormConfigComplete:(void (^)(LGEnterpriseConfig *config, NSError *))action {
    [LGManager getMessageFormConfigComplete:action];
}

+ (void)getTicketCategoryComplete:(void(^)(NSArray *categories))action {
    [LGManager getTicketCategoryComplete:action];
}

+ (void)submitMessageFormWithMessage:(NSString *)message images:(NSArray *)images clientInfo:(NSDictionary<NSString *,NSString *> *)clientInfo completion:(void (^)(BOOL, NSError *))completion {
//    [LGManager submitMessageFormWithMessage:message images:images clientInfo:clientInfo completion:completion];
    [LGManager submitTicketForm:message userInfo:clientInfo completion:^(LGTicket *ticket, NSError *e) {
        if (e) {
            completion(NO, e);
        } else {
            completion(YES, nil);
        }
    }];
}

+ (int)waitingInQueuePosition {
    return [LGManager waitingInQueuePosition];
}

+ (void)getClientQueuePositionComplete:(void (^)(NSInteger position, NSError *error))action {
    return [LGManager getClientQueuePositionComplete:action];
}

+ (void)requestPreChatServeyDataIfNeedCompletion:(void(^)(LGPreChatData *data, NSError *error))block {
    NSString *clientId = [LGChatViewConfig sharedConfig].LGClientId;
    NSString *customId = [LGChatViewConfig sharedConfig].customizedId;

    [LGManager requestPreChatServeyDataIfNeedWithClientId:clientId customizedId:customId completion:block];
}

+ (void)getCaptchaComplete:(void(^)(NSString *token, UIImage *image))block {
    [LGManager getCaptchaComplete:block];
}

+ (void)getCaptchaWithURLComplete:(void (^)(NSString *token, NSString *url))block {
    [LGManager getCaptchaURLComplete:block];
}

+ (void)submitPreChatForm:(NSDictionary *)formData completion:(void(^)(id,NSError *))block {
    [LGManager submitPreChatForm:formData completion:block];
}

+ (NSError *)checkGlobalError {
    return [LGManager checkGlobalError];
}

@end
