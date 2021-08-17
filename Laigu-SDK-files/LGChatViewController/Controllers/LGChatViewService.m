//
//  LGChatViewService.m
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/28.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//


#import "LGChatViewService.h"
#import "LGTextMessage.h"
#import "LGImageMessage.h"
#import "LGVoiceMessage.h"
#import "LGCardMessage.h"
#import "LGWithDrawMessage.h"
#import "LGBotAnswerMessage.h"
#import "LGBotMenuMessage.h"
#import "LGPhotoCardMessage.h"
#import "LGTextCellModel.h"
#import "LGCardCellModel.h"
#import "LGImageCellModel.h"
#import "LGVoiceCellModel.h"
#import "LGBotMenuCellModel.h"
#import "LGBotAnswerCellModel.h"
#import "LGRichTextViewModel.h"
#import "LGTipsCellModel.h"
#import "LGEvaluationResultCellModel.h"
#import "LGMessageDateCellModel.h"
#import "LGPhotoCardCellModel.h"
#import <UIKit/UIKit.h>
#import "LGToast.h"
#import "LGVoiceConverter.h"
#import "LGEventCellModel.h"
#import "LGAssetUtil.h"
#import "LGBundleUtil.h"
#import "LGFileDownloadCellModel.h"
#import "LGServiceToViewInterface.h"
#import <LaiGuSDK/LaiguSDK.h>
#import "LGBotMenuAnswerCellModel.h"
#import "LGWebViewBubbleCellModel.h"
#import "LGBotWebViewBubbleAnswerCellModel.h"
#import "LGCustomizedUIText.h"
#import "NSArray+LGFunctional.h"
#import "LGToast.h"
#import "NSError+LGConvenient.h"
#import "LGMessageFactoryHelper.h"
#import "LGBotMenuRichCellModel.h"
#import "LGSplitLineCellModel.h"

#import "LGBotMenuWebViewBubbleAnswerCellModel.h"

static NSInteger const kLGChatMessageMaxTimeInterval = 60;

/** 一次获取历史消息数的个数 */
static NSInteger const kLGChatGetHistoryMessageNumber = 20;

#ifdef INCLUDE_LAIGU_SDK
@interface LGChatViewService() <LGServiceToViewInterfaceDelegate, LGCellModelDelegate>

@property (nonatomic, strong) LGServiceToViewInterface *serviceToViewInterface;

@property (nonatomic, assign) BOOL noAgentTipShowed;

@property (nonatomic, weak) NSTimer *positionCheckTimer;

@property (nonatomic, strong) NSMutableArray *cacheTextArr;

@property (nonatomic, strong) NSMutableArray *cacheImageArr;

@property (nonatomic, strong) NSMutableArray *cacheFilePathArr;

@end
#else
@interface LGChatViewService() <LGCellModelDelegate>

@end
#endif

@implementation LGChatViewService {
#ifdef INCLUDE_LAIGU_SDK
    BOOL addedNoAgentTip;  //是否已经说明了没有客服标记
#endif
    //当前界面上显示的 message
//    NSMutableSet *currentViewMessageIdSet;
}

- (instancetype)initWithDelegate:(id<LGChatViewServiceDelegate>)delegate errorDelegate:(id<LGServiceToViewInterfaceErrorDelegate>)errorDelegate {
    if (self = [super init]) {
        self.cellModels = [[NSMutableArray alloc] init];
        addedNoAgentTip = false;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromBackground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanTimer) name:LG_NOTIFICATION_CHAT_END object:nil];
        
        self.positionCheckTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkAndUpdateWaitingQueueStatus) userInfo:nil repeats:YES];
//        currentViewMessageIdSet = [NSMutableSet new];
        
        self.delegate = delegate;
        self.errorDelegate = errorDelegate;
        
        [self addObserve];
        [self updateChatTitleWithAgent:nil state:LGStateAllocatingAgent];
    }
    return self;
}

- (void)addObserve {
    __weak typeof(self) wself = self;
    [LGManager addStateObserverWithBlock:^(LGState oldState, LGState newState, NSDictionary *value, NSError *error) {
        __strong typeof (wself) sself = wself;
        LGAgent *agent = value[@"agent"];
        
        NSString *agentType = [agent convertPrivilegeToString];
        
        [sself updateChatTitleWithAgent:agent state:newState];
        
        if (![agentType isEqualToString:@"bot"] && agentType.length > 0) {
            [sself removeBotTipCellModels];
            [sself.delegate reloadChatTableView];
        }
        
        if (newState == LGStateOffline) {
            if ([value[@"reason"] isEqualToString:@"autoconnect fail"]) {
                [sself.delegate showToastViewWithContent:@"网络故障"];
            }
        }
    } withKey:@"LGChatViewService"];
}

- (void)cleanTimer {
    if (self.positionCheckTimer.isValid) {
        [self.positionCheckTimer invalidate];
        self.positionCheckTimer = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [LGManager removeStateChangeObserverWithKey:@"LGChatViewService"];
}

//从后台返回到前台时 
- (void)backFromBackground {
    if ([LGServiceToViewInterface waitingInQueuePosition] > 0 || [LGServiceToViewInterface isBlacklisted]) {
        [self setClientOnline];
    }
}

- (LGState)clientStatus {
    return [LGManager getCurrentState];
}

#pragma 增加cellModel并刷新tableView
- (void)addCellModelAndReloadTableViewWithModel:(id<LGCellModelProtocol>)cellModel {
    if (![self.cellModels containsObject:cellModel]) {
        [self.cellModels addObject:cellModel];
        //        [self.delegate reloadChatTableView];
        //        [self.delegate scrollTableViewToBottomAnimated:YES];
        [self.delegate insertCellAtBottomForModelCount: 1];
    }
}

/**
 * 获取更多历史聊天消息
 */
- (void)startGettingHistoryMessages {
    NSDate *firstMessageDate = [self getFirstServiceCellModelDate];
    if ([LGChatViewConfig sharedConfig].enableSyncServerMessage) {// 默认开启消息同步
        [LGServiceToViewInterface getServerHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kLGChatGetHistoryMessageNumber successDelegate:self errorDelegate:self.errorDelegate];
    } else {
        [LGServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kLGChatGetHistoryMessageNumber delegate:self];
    }
}

/**
 * 在开启无消息访客过滤的条件下获取历史聊天信息
 */
- (void)getMessagesWithScheduleAfterClientSendMessage {
    NSDate *firstMessageDate = [self getFirstServiceCellModelDate];
    if ([LGChatViewConfig sharedConfig].enableSyncServerMessage) {// 默认开启消息同步
        [LGServiceToViewInterface getServerHistoryMessagesAndTicketsWithMsgDate:firstMessageDate messagesNumber:kLGChatGetHistoryMessageNumber successDelegate:self errorDelegate:self.errorDelegate];
    } else {
        [LGServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kLGChatGetHistoryMessageNumber delegate:self];
    }
}

/// 获取本地历史所有消息
- (void)startGettingDateBaseHistoryMessages{
    NSDate *firstMessageDate = [self getFirstServiceCellModelDate];
    [LGServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:kLGChatGetHistoryMessageNumber delegate:self];
}

//xlp  获取历史消息 从最后一条数据
- (void)startGettingHistoryMessagesFromLastMessage {
    NSDate *lastMessageDate = [self getLastServiceCellModelDate];

    if ([LGChatViewConfig sharedConfig].enableSyncServerMessage) {
        [LGServiceToViewInterface getServerHistoryMessagesWithMsgDate:lastMessageDate messagesNumber:kLGChatGetHistoryMessageNumber successDelegate:self errorDelegate:self.errorDelegate];
    } else {
        [LGServiceToViewInterface getDatabaseHistoryMessagesWithMsgDate:lastMessageDate messagesNumber:kLGChatGetHistoryMessageNumber delegate:self];
    }
}
/**
 *  获取最旧的cell的日期，例如text/image/voice等
 */
- (NSDate *)getFirstServiceCellModelDate {
    for (NSInteger index = 0; index < self.cellModels.count; index++) {
        id<LGCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
#pragma 开发者可在下面添加自己更多的业务cellModel 以便能正确获取历史消息
        if ([cellModel isKindOfClass:[LGTextCellModel class]] ||
            [cellModel isKindOfClass:[LGImageCellModel class]] ||
            [cellModel isKindOfClass:[LGVoiceCellModel class]] ||
            [cellModel isKindOfClass:[LGEventCellModel class]] ||
            [cellModel isKindOfClass:[LGFileDownloadCellModel class]] ||
            [cellModel isKindOfClass:[LGPhotoCardCellModel class]] ||
            [cellModel isKindOfClass:[LGWebViewBubbleCellModel class]] ||
            [cellModel isKindOfClass:[LGBotAnswerCellModel class]] ||
            [cellModel isKindOfClass:[LGBotMenuAnswerCellModel class]] ||
            [cellModel isKindOfClass:[LGBotMenuCellModel class]] ||
            [cellModel isKindOfClass:[LGBotMenuWebViewBubbleAnswerCellModel class]] ||
            [cellModel isKindOfClass:[LGBotWebViewBubbleAnswerCellModel class]] ||
            [cellModel isKindOfClass:[LGEvaluationResultCellModel class]])

        {
            return [cellModel getCellDate];
        }
    }
    return [NSDate date];
}

- (NSDate *)getLastServiceCellModelDate {
    for (NSInteger index = 0; index < self.cellModels.count; index++) {
        id<LGCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
      
        if (index == self.cellModels.count - 1) {

#pragma 开发者可在下面添加自己更多的业务cellModel 以便能正确获取历史消息
            if ([cellModel isKindOfClass:[LGTextCellModel class]] ||
                [cellModel isKindOfClass:[LGImageCellModel class]] ||
                [cellModel isKindOfClass:[LGVoiceCellModel class]] ||
                [cellModel isKindOfClass:[LGEventCellModel class]] ||
                [cellModel isKindOfClass:[LGFileDownloadCellModel class]] ||
                [cellModel isKindOfClass:[LGPhotoCardCellModel class]] ||
                [cellModel isKindOfClass:[LGWebViewBubbleCellModel class]] ||
                [cellModel isKindOfClass:[LGBotAnswerCellModel class]] ||
                [cellModel isKindOfClass:[LGBotMenuAnswerCellModel class]] ||
                [cellModel isKindOfClass:[LGBotMenuCellModel class]] ||
                [cellModel isKindOfClass:[LGBotMenuWebViewBubbleAnswerCellModel class]] ||
                [cellModel isKindOfClass:[LGBotWebViewBubbleAnswerCellModel class]] ||
                [cellModel isKindOfClass:[LGEvaluationResultCellModel class]])

            {
                return [cellModel getCellDate];
            }
        }
    }
    return [NSDate date];
}

#pragma mark - 消息发送

- (void)cacheSendText:(NSString *)text {
    [self.cacheTextArr addObject:text];
}

- (void)cacheSendImage:(UIImage *)image {
    [self.cacheImageArr addObject:image];
}

- (void)cacheSendAMRFilePath:(NSString *)filePath {
    [self.cacheFilePathArr addObject:filePath];
}

/**
 * 发送文字消息
 */
- (void)sendTextMessageWithContent:(NSString *)content {
    LGTextMessage *message = [[LGTextMessage alloc] initWithContent:content];
    message.conversionId = [LGServiceToViewInterface getCurrentConversationID] ?:@"";
    LGTextCellModel *cellModel = [[LGTextCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addConversionSplitLineWithCurrentCellModel:cellModel];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
    [LGServiceToViewInterface sendTextMessageWithContent:content messageId:message.messageId delegate:self];
}

/**
 * 发送图片消息
 */
- (void)sendImageMessageWithImage:(UIImage *)image {
    LGImageMessage *message = [[LGImageMessage alloc] initWithImage:image];
    message.conversionId = [LGServiceToViewInterface getCurrentConversationID] ?:@"";
    LGImageCellModel *cellModel = [[LGImageCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addConversionSplitLineWithCurrentCellModel:cellModel];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
#ifdef INCLUDE_LAIGU_SDK
    [LGServiceToViewInterface sendImageMessageWithImage:image messageId:message.messageId delegate:self];
#else
    //模仿发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellModel.sendStatus = LGChatMessageSendStatusSuccess;
        [self playSendedMessageSound];
    });
#endif
}

/**
 * 以AMR格式语音文件的形式，发送语音消息
 * @param filePath AMR格式的语音文件
 */
- (void)sendVoiceMessageWithAMRFilePath:(NSString *)filePath {
    //将AMR格式转换成WAV格式，以便使iPhone能播放
    NSData *wavData = [self convertToWAVDataWithAMRFilePath:filePath];
    LGVoiceMessage *message = [[LGVoiceMessage alloc] initWithVoiceData:wavData];
    [self sendVoiceMessageWithWAVData:wavData voiceMessage:message];
    NSData *amrData = [NSData dataWithContentsOfFile:filePath];
    [LGServiceToViewInterface sendAudioMessage:amrData messageId:message.messageId delegate:self];
}

/**
 * 以WAV格式语音数据的形式，发送语音消息
 * @param wavData WAV格式的语音数据
 */
- (void)sendVoiceMessageWithWAVData:(NSData *)wavData voiceMessage:(LGVoiceMessage *)message{
    message.conversionId = [LGServiceToViewInterface getCurrentConversationID] ?:@"";
    LGVoiceCellModel *cellModel = [[LGVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addConversionSplitLineWithCurrentCellModel:cellModel];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
#ifndef INCLUDE_LAIGU_SDK
    //模仿发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellModel.sendStatus = LGChatMessageSendStatusSuccess;
        [self playSendedMessageSound];
    });
#endif
}

/**
  删除消息
 */

- (void)deleteMessageAtIndex:(NSInteger)index withTipMsg:(NSString *)tipMsg enableLinesDisplay:(BOOL)enable{
    NSString *messageId = [[self.cellModels objectAtIndex:index] getCellMessageId];
    [LGServiceToViewInterface removeMessageInDatabaseWithId:messageId completion:nil];
    [self.cellModels removeObjectAtIndex:index];
    [self.delegate removeCellAtIndex:index];
    [self addTipCellModelWithTips:tipMsg enableLinesDisplay:enable];
}

/**
 * 重新发送消息
 * @param index 需要重新发送的index
 * @param resendData 重新发送的字典 [text/image/voice : data]
 */
- (void)resendMessageAtIndex:(NSInteger)index resendData:(NSDictionary *)resendData {
    //通知逻辑层删除该message数据
#ifdef INCLUDE_LAIGU_SDK
    NSString *messageId = [[self.cellModels objectAtIndex:index] getCellMessageId];
    [LGServiceToViewInterface removeMessageInDatabaseWithId:messageId completion:nil];
    
#endif
    [self.cellModels removeObjectAtIndex:index];
    [self.delegate removeCellAtIndex:index];
    //判断删除这个model的之前的model是否为date，如果是，则删除时间cellModel
    if (index < 0 || self.cellModels.count <= index-1) {
        return;
    }
    
    id<LGCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index-1];
    if (cellModel && [cellModel isKindOfClass:[LGMessageDateCellModel class]]) {
        [self.cellModels removeObjectAtIndex:index - 1];
        [self.delegate removeCellAtIndex:index - 1];
        index --;
        
    }
    
    if (self.cellModels.count > index) {
        id<LGCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
        if (cellModel && [cellModel isKindOfClass:[LGTipsCellModel class]]) {
            [self.cellModels removeObjectAtIndex:index];
            [self.delegate removeCellAtIndex:index];
        }
    }
    
    //重新发送
    if (resendData[@"text"]) {
        [self sendTextMessageWithContent:resendData[@"text"]];
    }
    if (resendData[@"image"]) {
        [self sendImageMessageWithImage:resendData[@"image"]];
    }
    if (resendData[@"voice"]) {
        [self sendVoiceMessageWithAMRFilePath:resendData[@"voice"]];
    }
}

/**
 * 发送“用户正在输入”的消息
 */
- (void)sendUserInputtingWithContent:(NSString *)content {
    [LGServiceToViewInterface sendClientInputtingWithContent:content];
}

/**
 *  在尾部增加cellModel之前，先判断两个时间间隔是否过大，如果过大，插入一个MessageDateCellModel
 *
 *  @param beAddedCellModel 准备被add的cellModel
 *  @return 是否插入了时间cell
 */
- (BOOL)addMessageDateCellAtLastWithCurrentCellModel:(id<LGCellModelProtocol>)beAddedCellModel {
    id<LGCellModelProtocol> lastCellModel = [self searchOneBussinessCellModelWithIndex:self.cellModels.count-1 isSearchFromBottomToTop:true];
    NSDate *lastDate = lastCellModel ? [lastCellModel getCellDate] : [NSDate date];
    NSDate *beAddedDate = [beAddedCellModel getCellDate];
    //判断被add的cell的时间比最后一个cell的时间是否要大（说明currentCell是第一个业务cell，此时显示时间cell）
    BOOL isLastDateLargerThanNextDate = lastDate.timeIntervalSince1970 > beAddedDate.timeIntervalSince1970;
    //判断被add的cell比最后一个cell的时间间隔是否超过阈值
    BOOL isDateTimeIntervalLargerThanThreshold = beAddedDate.timeIntervalSince1970 - lastDate.timeIntervalSince1970 >= kLGChatMessageMaxTimeInterval;
    if (!isLastDateLargerThanNextDate && !isDateTimeIntervalLargerThanThreshold) {
        return false;
    }
    LGMessageDateCellModel *cellModel = [[LGMessageDateCellModel alloc] initCellModelWithDate:beAddedDate cellWidth:self.chatViewWidth];
    if ([cellModel getCellMessageId].length > 0) {
        [self.cellModels addObject:cellModel];
        [self.delegate insertCellAtBottomForModelCount: 1];
    }
    return true;
}

/**
 *  在首部增加cellModel之前，先判断两个时间间隔是否过大，如果过大，插入一个MessageDateCellModel
 *
 *  @param beInsertedCellModel 准备被insert的cellModel
 *  @return 是否插入了时间cell
 */
- (BOOL)insertMessageDateCellAtFirstWithCellModel:(id<LGCellModelProtocol>)beInsertedCellModel {
    NSDate *firstDate = [NSDate date];
    if (self.cellModels.count == 0) {
        return false;
    }
    id<LGCellModelProtocol> firstCellModel = [self.cellModels objectAtIndex:0];
    if (![firstCellModel isServiceRelatedCell]) {
        return false;
    }
    NSDate *beInsertedDate = [beInsertedCellModel getCellDate];
    firstDate = [firstCellModel getCellDate];
    //判断被insert的Cell的date和第一个cell的date的时间间隔是否超过阈值
    BOOL isDateTimeIntervalLargerThanThreshold = firstDate.timeIntervalSince1970 - beInsertedDate.timeIntervalSince1970 >= kLGChatMessageMaxTimeInterval;
    if (!isDateTimeIntervalLargerThanThreshold) {
        return false;
    }
    LGMessageDateCellModel *cellModel = [[LGMessageDateCellModel alloc] initCellModelWithDate:firstDate cellWidth:self.chatViewWidth];
    [self.cellModels insertObject:cellModel atIndex:0];
    [self.delegate insertCellAtTopForModelCount: 1];
    return true;
}

/**
 *  在尾部增加cellModel之前，先判断两个message 是否是不同会话的，插入一个LGSplitLineCellModel
 *
 *  @param beAddedCellModel 准备被add的cellModel
 *  @return 是否插入
 */
- (BOOL)addConversionSplitLineWithCurrentCellModel:(id<LGCellModelProtocol>)beAddedCellModel {
    if(![LGServiceToViewInterface haveConversation] && beAddedCellModel.getMessageConversionId.length == 0) {
        if (_cellModels.count == 0) {
            return false;
        }
        id<LGCellModelProtocol> lastCellModel;
        bool haveSplit = false;
        for (id<LGCellModelProtocol> cellModel in [_cellModels reverseObjectEnumerator]) {
            if ([cellModel isKindOfClass:[LGSplitLineCellModel class]]) {
                haveSplit = true;
            }
            if ([cellModel getMessageConversionId].length > 0) {
                lastCellModel = cellModel;
                break;
            }
        }
        
        if (lastCellModel && !haveSplit) {
            LGSplitLineCellModel *cellModel = [[LGSplitLineCellModel alloc] initCellModelWithCellWidth:self.chatViewWidth withConversionDate:[beAddedCellModel getCellDate]];
            [self.cellModels addObject:cellModel];
            [self.delegate insertCellAtBottomForModelCount: 1];
            return true;
        }
        return false;
    }
    
    LGSplitLineCellModel *cellModel = [self insertConversionSplitLineWithCellModel:beAddedCellModel withCellModels:_cellModels];
    if (cellModel) {
        [self.cellModels addObject:cellModel];
        [self.delegate insertCellAtBottomForModelCount: 1];
        return true;
    }
    return false;
}

/**
 *  判断是否需要加入不同回话的分割线
 *
 *  @param beInsertedCellModel 准备被insert的cellModel
 */
- (LGSplitLineCellModel *)insertConversionSplitLineWithCellModel:(id<LGCellModelProtocol>)beInsertedCellModel withCellModels:(NSArray *) cellModelArr {
    if (cellModelArr.count == 0) {
        return nil;
    }
    id<LGCellModelProtocol> lastCellModel;
    for (id<LGCellModelProtocol> cellModel in [cellModelArr reverseObjectEnumerator]) {
        if ([cellModel getMessageConversionId].length > 0) {
            lastCellModel = cellModel;
            break;
        }
    }
    if (!lastCellModel) {
        return nil;
    }
    
    if ([beInsertedCellModel getMessageConversionId].length > 0 && ![lastCellModel.getMessageConversionId isEqualToString:beInsertedCellModel.getMessageConversionId]) {
        LGSplitLineCellModel *cellModel1 = [[LGSplitLineCellModel alloc] initCellModelWithCellWidth:self.chatViewWidth withConversionDate:[beInsertedCellModel getCellDate]];
        return cellModel1;
    }
    return nil;
}

/**
 * 从后往前从cellModels中获取到业务相关的cellModel，即text, image, voice等；
 */
/**
 *  从cellModels中搜索第一个业务相关的cellModel，即text, image, voice等；
 *  @warning 业务相关的cellModel，必须满足协议方法isServiceRelatedCell
 *
 *  @param searchIndex             search的起始位置
 *  @param isSearchFromBottomToTop search的方向 YES：从后往前搜索  NO：从前往后搜索
 *
 *  @return 搜索到的第一个业务相关的cellModel
 */
- (id<LGCellModelProtocol>)searchOneBussinessCellModelWithIndex:(NSInteger)searchIndex isSearchFromBottomToTop:(BOOL)isSearchFromBottomToTop{
    if (self.cellModels.count <= searchIndex) {
        return nil;
    }
    id<LGCellModelProtocol> cellModel = [self.cellModels objectAtIndex:searchIndex];
    //判断获取到的cellModel是否是业务相关的cell，如果不是则继续往前取
    if ([cellModel isServiceRelatedCell]){
        return cellModel;
    }
    NSInteger nextSearchIndex = isSearchFromBottomToTop ? searchIndex - 1 : searchIndex + 1;
    [self searchOneBussinessCellModelWithIndex:nextSearchIndex isSearchFromBottomToTop:isSearchFromBottomToTop];
    return nil;
}

/**
 * 通知viewController更新tableView；
 */
- (void)reloadChatTableView {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(reloadChatTableView)]) {
            [self.delegate reloadChatTableView];
        }
    }
}

- (void)scrollToBottom {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollTableViewToBottomAnimated:)]) {
            [self.delegate scrollTableViewToBottomAnimated: NO];
        }
    }
}

#ifndef INCLUDE_LAIGU_SDK
/**
 * 使用LGChatViewControllerDemo的时候，调试用的方法，用于收取和上一个message一样的消息
 */
- (void)loadLastMessage {
    id<LGCellModelProtocol> lastCellModel = [self searchOneBussinessCellModelWithIndex:self.cellModels.count-1 isSearchFromBottomToTop:true];
    if (lastCellModel) {
        if ([lastCellModel isKindOfClass:[LGTextCellModel class]]) {
            LGTextCellModel *textCellModel = (LGTextCellModel *)lastCellModel;
            LGTextMessage *message = [[LGTextMessage alloc] initWithContent:[textCellModel.cellText string]];
            message.fromType = LGChatMessageIncoming;
            LGTextCellModel *newCellModel = [[LGTextCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
            [self.delegate insertCellAtBottomForModelCount:1];
            
        } else if ([lastCellModel isKindOfClass:[LGImageCellModel class]]) {
            LGImageCellModel *imageCellModel = (LGImageCellModel *)lastCellModel;
            LGImageMessage *message = [[LGImageMessage alloc] initWithImage:imageCellModel.image];
            message.fromType = LGChatMessageIncoming;
            LGImageCellModel *newCellModel = [[LGImageCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
            [self.delegate insertCellAtBottomForModelCount:1];
        } else if ([lastCellModel isKindOfClass:[LGVoiceCellModel class]]) {
            LGVoiceCellModel *voiceCellModel = (LGVoiceCellModel *)lastCellModel;
            LGVoiceMessage *message = [[LGVoiceMessage alloc] initWithVoiceData:voiceCellModel.voiceData];
            message.fromType = LGChatMessageIncoming;
            LGVoiceCellModel *newCellModel = [[LGVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
            [self.delegate insertCellAtBottomForModelCount:1];
        }
    }
    //text message
    LGTextMessage *textMessage = [[LGTextMessage alloc] initWithContent:@"Let's Rooooooooooock~"];
    textMessage.fromType = LGChatMessageIncoming;
    LGTextCellModel *textCellModel = [[LGTextCellModel alloc] initCellModelWithMessage:textMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:textCellModel];
    [self.delegate insertCellAtBottomForModelCount:1];
    //image message
    LGImageMessage *imageMessage = [[LGImageMessage alloc] initWithImagePath:@"https://s3.cn-north-1.amazonaws.com.cn/pics.laigu.bucket/65135e4c4fde7b5f"];
    imageMessage.fromType = LGChatMessageIncoming;
    LGImageCellModel *imageCellModel = [[LGImageCellModel alloc] initCellModelWithMessage:imageMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:imageCellModel];
    [self.delegate insertCellAtBottomForModelCount:1];
    //tip message
//        LGTipsCellModel *tipCellModel = [[LGTipsCellModel alloc] initCellModelWithTips:@"主人，您的客服离线啦~" cellWidth:self.cellWidth enableLinesDisplay:true];
//        [self.cellModels addObject:tipCellModel];
    //voice message
    LGVoiceMessage *voiceMessage = [[LGVoiceMessage alloc] initWithVoicePath:@"http://7xiy8i.com1.z0.glb.clouddn.com/test.amr"];
    voiceMessage.fromType = LGChatMessageIncoming;
    LGVoiceCellModel *voiceCellModel = [[LGVoiceCellModel alloc] initCellModelWithMessage:voiceMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:voiceCellModel];
    [self.delegate insertCellAtBottomForModelCount:1];
    // bot answer cell
    LGBotAnswerMessage *botAnswerMsg = [[LGBotAnswerMessage alloc] initWithContent:@"这个是一个机器人的回答。" subType:@"" isEvaluated:false];
    botAnswerMsg.fromType = LGChatMessageIncoming;
    LGBotAnswerCellModel *botAnswerCellmodel = [[LGBotAnswerCellModel alloc] initCellModelWithMessage:botAnswerMsg cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:botAnswerCellmodel];
    [self.delegate insertCellAtBottomForModelCount:1];
    // bot menu cell
    LGBotMenuMessage *botMenuMsg = [[LGBotMenuMessage alloc] initWithContent:@"你是不是想问下面这些问题？" menu:@[@"1. 第一个 menu，说点儿什么呢，换个行吧啦啦啦", @"2. 再来一个 menu", @"3. 最后一个 menu"]];
    botMenuMsg.fromType = LGChatMessageIncoming;
    LGBotMenuCellModel *botMenuCellModel = [[LGBotMenuCellModel alloc] initCellModelWithMessage:botMenuMsg cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:botMenuCellModel];
    [self.delegate insertCellAtBottomForModelCount: 1];
    [self playReceivedMessageSound];
}

#endif

#pragma LGCellModelDelegate
- (void)didUpdateCellDataWithMessageId:(NSString *)messageId {
    //获取又更新的cell的index
    NSInteger index = [self getIndexOfCellWithMessageId:messageId];
    if (index < 0 || index > self.cellModels.count - 1) {
        return;
    }
    [self updateCellWithIndex:index needToBottom:NO];
}

- (NSInteger)getIndexOfCellWithMessageId:(NSString *)messageId {
    for (NSInteger index=0; index<self.cellModels.count; index++) {
        id<LGCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
        if ([[cellModel getCellMessageId] isEqualToString:messageId]) {
            //更新该cell
            return index;
        }
    }
    return -1;
}

//通知tableView更新该indexPath的cell
- (void)updateCellWithIndex:(NSInteger)index needToBottom:(BOOL)toBottom {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didUpdateCellModelWithIndexPath:needToBottom:)]) {
            [self.delegate didUpdateCellModelWithIndexPath:indexPath needToBottom:toBottom];
        }
    }
}

#pragma AMR to WAV转换
- (NSData *)convertToWAVDataWithAMRFilePath:(NSString *)amrFilePath {
    NSString *tempPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    tempPath = [tempPath stringByAppendingPathComponent:@"record.wav"];
    [LGVoiceConverter amrToWav:amrFilePath wavSavePath:tempPath];
    NSData *wavData = [NSData dataWithContentsOfFile:tempPath];
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    return wavData;
}

#pragma 更新cellModel中的frame
- (void)updateCellModelsFrame {
    for (id<LGCellModelProtocol> cellModel in self.cellModels) {
        [cellModel updateCellFrameWithCellWidth:self.chatViewWidth];
    }
}

#pragma 欢迎语
- (void)sendLocalWelcomeChatMessage {
    if (![LGChatViewConfig sharedConfig].enableChatWelcome) {
        return ;
    }
    //消息时间
    LGMessageDateCellModel *dateCellModel = [[LGMessageDateCellModel alloc] initCellModelWithDate:[NSDate date] cellWidth:self.chatViewWidth];
    [self.cellModels addObject:dateCellModel];
    [self.delegate insertCellAtBottomForModelCount:1];
    //欢迎消息
    LGTextMessage *welcomeMessage = [[LGTextMessage alloc] initWithContent:[LGChatViewConfig sharedConfig].chatWelcomeText];
    welcomeMessage.fromType = LGChatMessageIncoming;
    welcomeMessage.userName = [LGChatViewConfig sharedConfig].agentName;
    welcomeMessage.userAvatarImage = [LGChatViewConfig sharedConfig].incomingDefaultAvatarImage;
    welcomeMessage.sendStatus = LGChatMessageSendStatusSuccess;
    LGTextCellModel *cellModel = [[LGTextCellModel alloc] initCellModelWithMessage:welcomeMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:cellModel];
    [self.delegate insertCellAtBottomForModelCount: 1];
}

#pragma 点击了某个cell
- (void)didTapMessageCellAtIndex:(NSInteger)index {
    id<LGCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
    if ([cellModel isKindOfClass:[LGVoiceCellModel class]]) {
        LGVoiceCellModel *voiceCellModel = (LGVoiceCellModel *)cellModel;
        [voiceCellModel setVoiceHasPlayed];
//        #ifdef INCLUDE_LAIGU_SDK
//        [LGServiceToViewInterface didTapMessageWithMessageId:[cellModel getCellMessageId]];
//#endif
    }
}

#pragma 播放声音
- (void)playReceivedMessageSound {
    if (![LGChatViewConfig sharedConfig].enableMessageSound || [LGChatViewConfig sharedConfig].incomingMsgSoundFileName.length == 0) {
        return;
    }
    [LGChatFileUtil playSoundWithSoundFile:[LGAssetUtil resourceWithName:[LGChatViewConfig sharedConfig].incomingMsgSoundFileName]];
}

- (void)playSendedMessageSound {
    if (![LGChatViewConfig sharedConfig].enableMessageSound || [LGChatViewConfig sharedConfig].outgoingMsgSoundFileName.length == 0) {
        return;
    }
    [LGChatFileUtil playSoundWithSoundFile:[LGAssetUtil resourceWithName:[LGChatViewConfig sharedConfig].outgoingMsgSoundFileName]];
}

#pragma mark - create model
- (id<LGCellModelProtocol>)createCellModelWith:(LGBaseMessage *)message {
    id<LGCellModelProtocol> cellModel = nil;
    if (![message isKindOfClass:[LGEventMessage class]]) {
        if ([message isKindOfClass:[LGTextMessage class]]) {
            cellModel = [[LGTextCellModel alloc] initCellModelWithMessage:(LGTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[LGImageMessage class]]) {
            cellModel = [[LGImageCellModel alloc] initCellModelWithMessage:(LGImageMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[LGVoiceMessage class]]) {
            cellModel = [[LGVoiceCellModel alloc] initCellModelWithMessage:(LGVoiceMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[LGFileDownloadMessage class]]) {
            cellModel = [[LGFileDownloadCellModel alloc] initCellModelWithMessage:(LGFileDownloadMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[LGRichTextMessage class]]) {
            
            if ([message isKindOfClass:[LGBotRichTextMessage class]]) {
                
                if ([(LGBotRichTextMessage *)message menu] != nil) {

                    if ([[(LGBotRichTextMessage *)message subType] isEqualToString:@"evaluate"]) {
                        cellModel = [[LGBotMenuWebViewBubbleAnswerCellModel alloc] initCellModelWithMessage:(LGBotRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                    } else {
                        cellModel = [[LGWebViewBubbleCellModel alloc] initCellModelWithMessage:(LGRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                    }

                } else {

                    if ([[(LGBotRichTextMessage *)message subType] isEqualToString:@"evaluate"]) {
                        cellModel = [[LGBotWebViewBubbleAnswerCellModel alloc] initCellModelWithMessage:(LGBotRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                    } else {
                        cellModel = [[LGWebViewBubbleCellModel alloc] initCellModelWithMessage:(LGRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                    }
                }
                
            } else {
                // 原富文本模型用webviewBubble代替
                cellModel = [[LGWebViewBubbleCellModel alloc] initCellModelWithMessage:(LGRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
                
//                cellModel = [[LGRichTextViewModel alloc] initCellModelWithMessage:(LGRichTextMessage *)message cellWidth:self.chatViewWidth delegate:self];

            }
            
        }else if ([message isKindOfClass:[LGBotAnswerMessage class]]) {
            
            if ([(LGBotAnswerMessage *)message menu] == nil) {
                cellModel = [[LGBotAnswerCellModel alloc] initCellModelWithMessage:(LGBotAnswerMessage *)message cellWidth:self.chatViewWidth delegate:self];
            } else {
                cellModel = [[LGBotMenuAnswerCellModel alloc] initCellModelWithMessage:(LGBotAnswerMessage *)message cellWidth:self.chatViewWidth delegate:self];
            }
        } else if ([message isKindOfClass:[LGBotMenuMessage class]]) {
//            cellModel = [[LGBotMenuRichCellModel alloc] initCellModelWithMessage:(LGBotMenuMessage *)message cellWidth:self.chatViewWidth delegate:self];
            
            cellModel = [[LGBotMenuCellModel alloc] initCellModelWithMessage:(LGBotMenuMessage *)message cellWidth:self.chatViewWidth delegate:self];
            
        } else if ([message isKindOfClass:[LGCardMessage class]]) {
            cellModel = [[LGCardCellModel alloc] initCellModelWithMessage:(LGCardMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[LGWithDrawMessage class]]) {
            // 消息撤回
            LGWithDrawMessage *withDrawMessage = (LGWithDrawMessage *)message;
            cellModel = [[LGTipsCellModel alloc] initCellModelWithTips:withDrawMessage.content cellWidth:self.chatViewWidth enableLinesDisplay:NO];
        } else if ([message isKindOfClass:[LGPhotoCardMessage class]]) {
            cellModel = [[LGPhotoCardCellModel alloc] initCellModelWithMessage:(LGPhotoCardMessage *)message cellWidth:self.chatViewWidth delegate:self];
       }
    }
    return cellModel;
}

#pragma mark - 消息保存到cellmodel中
/**
 *  将消息数组中的消息转换成cellModel，并添加到cellModels中去;
 *
 *  @param newMessages             消息实体array
 *  @param isInsertAtFirstIndex 是否将messages插入到顶部
 *
 *  @return 返回转换为cell的个数
 */
- (NSInteger)saveToCellModelsWithMessages:(NSArray *)newMessages isInsertAtFirstIndex:(BOOL)isInsertAtFirstIndex {
    
    NSMutableArray *newCellModels = [NSMutableArray new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [LGServiceToViewInterface updateMessageIds:[newMessages valueForKey:@"messageId"] toReadStatus:YES];
    });
    
    // 1. 如果相同 messaeg Id 的 cell model 存在，则替换，否则追加
    for (LGBaseMessage *message in newMessages) {
        id<LGCellModelProtocol> newCellModel = [self createCellModelWith:message];
        
        if (!newCellModel) { // EventMessage 不会生成 cell model
            continue;
        }
        
//        // 如果富文本为空，不显示
//        if ([newCellModel isKindOfClass:[LGWebViewBubbleCellModel class]]) {
//            LGRichTextMessage *richMessage = (LGRichTextMessage *)message;
//            if ([richMessage.content isEqual:[NSNull null]] || richMessage.content.length == 0) {
//                NSLog(@"--- 空的富文本");
//                continue;
//            }
//        }
        
         NSArray *redundentCellModels = [self.cellModels filter:^BOOL(id<LGCellModelProtocol> cellModel) {
            return [[cellModel getCellMessageId] isEqualToString:[newCellModel getCellMessageId]];
         }];
        
        if ([redundentCellModels count] > 0) {
            [self.cellModels replaceObjectAtIndex:[self.cellModels indexOfObject:[redundentCellModels firstObject]] withObject:newCellModel];
        } else {
            LGSplitLineCellModel *splitLineCellModel = [self insertConversionSplitLineWithCellModel:newCellModel withCellModels:newCellModels];
            if (splitLineCellModel) {
                [newCellModels addObject:splitLineCellModel];
            }
            [newCellModels addObject:newCellModel];
        }
    }
    
    // 2. 计算新的 cell model 在列表中的位置
    NSMutableSet *positionVector = [NSMutableSet new]; // 计算位置的辅助容器，如果所有消息都为 0，放在底部，都为 1，放在顶部，两者都有，则需要重新排序。
    NSDate *firstMessageDate = [self.cellModels.firstObject getCellDate];
    NSDate *lastMessageDate = [self.cellModels.lastObject getCellDate];
    [newCellModels enumerateObjectsUsingBlock:^(id<LGCellModelProtocol> newCellModel, NSUInteger idx, BOOL * stop) {
        if (![newCellModel isKindOfClass:[LGSplitLineCellModel class]]) {
            if ([firstMessageDate compare:[newCellModel getCellDate]] == NSOrderedDescending) {
                [positionVector addObject:@"1"];
            } else if ([lastMessageDate compare:[newCellModel getCellDate]] == NSOrderedAscending) {
                [positionVector addObject:@"0"];
            }
        }
    }];
    
    if (positionVector.count > 1) {
        positionVector = [[NSMutableSet alloc] initWithObjects:@"2", nil];
    }
    
    __block NSUInteger position = 0; // 0: bottom, 1: top, 2: random
    
    [positionVector enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        position = [obj intValue];
    }];
    
    if (newCellModels.count == 0) { return 0; }
    // 判断是否需要添加分割线
    if (position == 1) {
        id <LGCellModelProtocol> currentFirstCellModel;
        for (id<LGCellModelProtocol> cellModel in self.cellModels) {
            if ([cellModel getMessageConversionId].length > 0) {
                currentFirstCellModel = cellModel;
                break;
            }
        }
        if (!currentFirstCellModel) {
            LGSplitLineCellModel *splitLineCellModel = [self insertConversionSplitLineWithCellModel:currentFirstCellModel withCellModels:newCellModels];
            if (splitLineCellModel) {
                [newCellModels addObject:splitLineCellModel];
            }
        }
    } else if (position == 0) {
        LGSplitLineCellModel *splitLineCellModel = [self insertConversionSplitLineWithCellModel:[newCellModels firstObject] withCellModels:self.cellModels];
        if (splitLineCellModel) {
            [newCellModels insertObject:splitLineCellModel atIndex:0];
        }
    }
    NSUInteger newMessageCount = newCellModels.count;
    switch (position) {
        case 1: // top
            [self insertMessageDateCellAtFirstWithCellModel:[newCellModels firstObject]]; // 如果需要，顶部插入时间
            self.cellModels = [[newCellModels arrayByAddingObjectsFromArray:self.cellModels] mutableCopy];
            break;
        case 0: // bottom
            [self addMessageDateCellAtLastWithCurrentCellModel:[newCellModels firstObject]];// 如果需要，底部插入时间
            [self.cellModels addObjectsFromArray:newCellModels];
            break;
        default:
            [self.cellModels addObjectsFromArray:newCellModels];// 退出后会被重新排序，这种情况只可能出现在聊天过程中 socket 断开后，轮询后台消息，会比自己发的消息早，但是应该放到前面。
            break;
    }
    
    return newMessageCount;
}

/**
 *  发送用户评价
 */
- (void)sendEvaluationLevel:(NSInteger)level comment:(NSString *)comment {
    //生成评价结果的 cell
    LGEvaluationType levelType = LGEvaluationTypePositive;
    switch (level) {
        case 0:
            levelType = LGEvaluationTypeNegative;
            break;
        case 1:
            levelType = LGEvaluationTypeModerate;
            break;
        case 2:
            levelType = LGEvaluationTypePositive;
            break;
        default:
            break;
    }
    [self showEvaluationCellWithLevel:levelType comment:comment];
#ifdef INCLUDE_LAIGU_SDK
    [LGServiceToViewInterface setEvaluationLevel:level comment:comment];
#endif
}

//显示用户评价的 cell
- (void)showEvaluationCellWithLevel:(LGEvaluationType)level comment:(NSString *)comment{
    LGEvaluationResultCellModel *cellModel = [[LGEvaluationResultCellModel alloc] initCellModelWithEvaluation:level comment:comment cellWidth:self.chatViewWidth];
    [self.cellModels addObject:cellModel];
    [self.delegate insertCellAtBottomForModelCount: 1];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollTableViewToBottomAnimated:)]) {
            [self.delegate scrollTableViewToBottomAnimated: YES];
        }
    }
}

- (void)addTipCellModelWithTips:(NSString *)tips enableLinesDisplay:(BOOL)enableLinesDisplay {
    LGTipsCellModel *cellModel = [[LGTipsCellModel alloc] initCellModelWithTips:tips cellWidth:self.chatViewWidth enableLinesDisplay:enableLinesDisplay];
    [self.cellModels addObject:cellModel];
    [self.delegate insertCellAtBottomForModelCount: 1];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollTableViewToBottomAnimated:)]) {
            [self.delegate scrollTableViewToBottomAnimated: YES];
        }
    }
}

// 增加留言提示的 cell model
- (void)addTipCellModelWithType:(LGTipType)tipType {
    // 判断当前是否是机器人客服
    if ([LGServiceToViewInterface getCurrentAgent].privilege != LGAgentPrivilegeBot) {
        return;
    }
    // 判断 table 中是否出现「转人工」或「留言」，如果出现过，并不在最后一个 cell，则将之移到底部
    LGTipsCellModel *tipModel = nil;
    if (tipType == LGTipTypeReply || tipType == LGTipTypeBotRedirect || tipType == LGTipTypeBotManualRedirect) {
        for (id<LGCellModelProtocol> model in self.cellModels) {
            if ([model isKindOfClass:[LGTipsCellModel class]]) {
                LGTipsCellModel *cellModel = (LGTipsCellModel *)model;
                if (cellModel.tipType == tipType) {
                    tipModel = cellModel;
                    break;
                }
            }
        }
    }
    if (tipModel) {
        // 将目标 model 移到最底部
        [self.cellModels removeObject:tipModel];
        [self.cellModels addObject:tipModel];
        [self.delegate reloadChatTableView];
    } else {
        LGTipsCellModel *cellModel = [[LGTipsCellModel alloc] initBotTipCellModelWithCellWidth:self.chatViewWidth tipType:tipType];
        [self.cellModels addObject:cellModel];
        [self.delegate insertCellAtBottomForModelCount: 1];
    }
    [self scrollToBottom];
}

// 清除当前界面的「转人工」「留言」的 tipCell
- (void)removeBotTipCellModels {
    NSMutableArray *newCellModels = [NSMutableArray new];
    for (id<LGCellModelProtocol> model in self.cellModels) {
        if ([model isKindOfClass:[LGTipsCellModel class]]) {
            LGTipsCellModel *cellModel = (LGTipsCellModel *)model;
            if (cellModel.tipType == LGTipTypeReply || cellModel.tipType == LGTipTypeBotRedirect || cellModel.tipType == LGTipTypeBotManualRedirect) {
                continue;
            }
        }
        [newCellModels addObject:model];
    }
    self.cellModels = newCellModels;
}

- (void)addWaitingInQueueTipWithPosition:(int)position {
    [LGServiceToViewInterface getEnterpriseConfigInfoWithCache:YES complete:^(LGEnterprise *enterPrise, NSError *error) {
        if (enterPrise.configInfo.queueStatus) {
            [self removeWaitingInQueueCellModels];
            [self.delegate reloadChatTableView];
            LGTipsCellModel *cellModel = [[LGTipsCellModel alloc] initWaitingInQueueTipCellModelWithCellWidth:self.chatViewWidth withIntro:enterPrise.configInfo.queueIntro ticketIntro:enterPrise.configInfo.queueTicketIntro position:position tipType:LGTipTypeWaitingInQueue];
            [self.cellModels addObject:cellModel];
            [self.delegate insertCellAtBottomForModelCount: 1];
            [self scrollToBottom];
        }
    }];
}

/// 清除当前界面的排队中「留言」的 tipCell
- (void)removeWaitingInQueueCellModels {
    NSMutableArray *newCellModels = [NSMutableArray new];
    for (id<LGCellModelProtocol> model in self.cellModels) {
        if ([model isKindOfClass:[LGTipsCellModel class]]) {
            LGTipsCellModel *cellModel = (LGTipsCellModel *)model;
            if (cellModel.tipType == LGTipTypeWaitingInQueue) {
                continue;
            }
        }
        [newCellModels addObject:model];
    }
    self.cellModels = newCellModels;
}

#ifdef INCLUDE_LAIGU_SDK

#pragma mark - 顾客上线的逻辑
//上线
- (void)setClientOnline {
    if (self.clientStatus == LGStateAllocatingAgent) {
        return;
    }
    // [LGChatViewConfig sharedConfig].scheduleRule 默认为0，不限制分配规则
    [LGServiceToViewInterface setScheduledAgentWithAgentId:[LGChatViewConfig sharedConfig].scheduledAgentId agentGroupId:[LGChatViewConfig sharedConfig].scheduledGroupId scheduleRule:[LGChatViewConfig sharedConfig].scheduleRule];
    
    if ([LGChatViewConfig sharedConfig].LGClientId.length == 0 && [LGChatViewConfig sharedConfig].customizedId.length > 0) {
        [self onlineWithCustomizedId];
    } else {
        [self onlineWithClientId];
    }
    
//    // 每次上线，手动刷新一次等待提醒
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self checkAndUpdateWaitingQueueStatus];
//    });

}

// 连接客服上线
- (void)onlineWithClientId {
    __weak typeof(self) weakSelf = self;
    NSDate *msgDate = [NSDate date];

    [self.serviceToViewInterface setClientOnlineWithClientId:[LGChatViewConfig sharedConfig].LGClientId success:^(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if ([error reason].length == 0) {
            [strongSelf removeScheduledAgentWithType:agentType];
            if (receivedMessages.count <= 0) {
                [LGManager getDatabaseHistoryMessagesWithMsgDate:msgDate messagesNumber:0 result:^(NSArray<LGMessage *> *messagesArray) {
                    NSArray *toMessages = [strongSelf convertToChatViewMessageWithLGMessages:messagesArray];
                    [strongSelf handleClientOnlineWithRreceivedMessages:toMessages completeStatus:completion];
                }];
            }else{
                [strongSelf handleClientOnlineWithRreceivedMessages:receivedMessages completeStatus:completion];
            }
        } else {
            [LGToast showToast:[error shortDescription] duration:2.0 window:[[UIApplication sharedApplication].windows lastObject]];
        }
    } receiveMessageDelegate:self];
}

- (void)removeScheduledAgentWithType:(NSString *)agentType {
    if (![agentType isEqualToString:@"bot"]) {
        [LGServiceToViewInterface deleteScheduledAgent];
    }
}

#pragma mark - message转为UI类型
- (NSArray *)convertToChatViewMessageWithLGMessages:(NSArray *)messagesArray {
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


- (void)onlineWithCustomizedId {
    __weak typeof(self) weakSelf = self;
    NSDate *msgDate = [NSDate date];

    [self.serviceToViewInterface setClientOnlineWithCustomizedId:[LGChatViewConfig sharedConfig].customizedId success:^(BOOL completion, NSString *agentName, NSString *agentType, NSArray *receivedMessages, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if ([error reason].length == 0) {
            [strongSelf removeScheduledAgentWithType:agentType];
            if (receivedMessages.count <= 0) {
                [LGManager getDatabaseHistoryMessagesWithMsgDate:msgDate messagesNumber:0 result:^(NSArray<LGMessage *> *messagesArray) {
                    NSArray *toMessages = [strongSelf convertToChatViewMessageWithLGMessages:messagesArray];
                    [strongSelf handleClientOnlineWithRreceivedMessages:toMessages completeStatus:completion];
                }];
            }else{
                [strongSelf handleClientOnlineWithRreceivedMessages:receivedMessages completeStatus:completion];
            }
        } else {
            [LGToast showToast:[error shortDescription] duration:2.5 window:[[UIApplication sharedApplication].windows lastObject]];
        }    } receiveMessageDelegate:self];
}

- (void)handleClientOnlineWithRreceivedMessages:(NSArray *)receivedMessages
                         completeStatus:(BOOL)completion
{
    if (receivedMessages) {
        NSInteger newCellCount = [self saveToCellModelsWithMessages:receivedMessages isInsertAtFirstIndex: NO];
        [UIView setAnimationsEnabled:NO];
        [self.delegate insertCellAtTopForModelCount: newCellCount];
        [self scrollToBottom];
        [UIView setAnimationsEnabled:YES];
        [self.delegate reloadChatTableView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollToBottom]; // some image may lead the table didn't reach bottom
        });
    }
    
    [self afterClientOnline];
}

- (void)afterClientOnline {
    __weak typeof(self) wself = self;
    //上传顾客信息
    [self setCurrentClientInfoWithCompletion:^(BOOL success) {
        //获取顾客信息
        __strong typeof (wself) sself = wself;
        [sself getClientInfo];
    }];
    
    [self sendPreSendMessages];
    
    int position = [LGServiceToViewInterface waitingInQueuePosition];
    if (position > 0) {
        [self addWaitingInQueueTipWithPosition:position];
        LGInfo(@"now you are at %d in waiting queue", position);
    }
    
    NSError * error = [LGServiceToViewInterface checkGlobalError];
    if (error) {
        if (error.code == LGErrorCodeBotFailToRedirectToHuman) {
            [self addTipCellModelWithType:LGTipTypeReply];
        }
    }
    
    [LGServiceToViewInterface getEnterpriseConfigInfoWithCache:YES complete:^(LGEnterprise *enterprise, NSError *e) {
        [LGCustomizedUIText setCustomiedTextForKey:(LGUITextKeyNoAgentTip) text:enterprise.configInfo.ticketConfigInfo.intro];
    }];
}

- (void)checkAndUpdateWaitingQueueStatus {
    //如果之前在排队中，则继续查询
    if ([LGServiceToViewInterface waitingInQueuePosition] > 0) {
        LGInfo(@"check wating queue position")
        [LGServiceToViewInterface getClientQueuePositionComplete:^(NSInteger position, NSError *error) {
            if (position > 0) {
                [self addWaitingInQueueTipWithPosition:(int)position];
                LGInfo(@"now you are at %d in waiting queue", (int)position);
            } else {
                [self removeWaitingInQueueCellModels];
                [self removeBotTipCellModels];
                [self reloadChatTableView];
            }
        }];
    } else {
        [self removeBotTipCellModels];
        [self removeWaitingInQueueCellModels];
        [self reloadChatTableView];
        [self.positionCheckTimer invalidate];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendPreSendMessages];
        });
    }
}


#define kSaveTextDraftIfNeeded @"kSaveTextDraftIfNeeded"
- (void)saveTextDraftIfNeeded:(UITextField *)tf {
    if (tf.text.length) {
        [[NSUserDefaults standardUserDefaults]setObject:tf.text forKey:kSaveTextDraftIfNeeded];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)fillTextDraftToFiledIfExists:(UITextField *)tf {
    NSString *string = [[NSUserDefaults standardUserDefaults]objectForKey:kSaveTextDraftIfNeeded];
    if (string.length) {
        tf.text = string;
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:kSaveTextDraftIfNeeded];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)sendPreSendMessages {
//    if ([LGServiceToViewInterface getCurrentAgentStatus] == LGChatAgentStatusOnDuty) {
        for (id messageContent in [LGChatViewConfig sharedConfig].preSendMessages) {
            if ([messageContent isKindOfClass:NSString.class]) {
                [self sendTextMessageWithContent:messageContent];
            } else if ([messageContent isKindOfClass:UIImage.class]) {
                [self sendImageMessageWithImage:messageContent];
            }
        }
        
        [LGChatViewConfig sharedConfig].preSendMessages = nil;
//    }
}

//获取顾客信息
- (void)getClientInfo {
    NSDictionary *localClientInfo = [LGChatViewConfig sharedConfig].clientInfo;
    NSDictionary *remoteClientInfo = [LGServiceToViewInterface getCurrentClientInfo];
    NSString *avatarPath = [localClientInfo objectForKey:@"avatar"];
    if ([avatarPath length] == 0) {
        avatarPath = remoteClientInfo[@"avatar"];
        if (avatarPath.length == 0) {
            return;
        }
    }
    
    [LGServiceToViewInterface downloadMediaWithUrlString:avatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
        if (mediaData) {
            [LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage = [UIImage imageWithData:mediaData];
            [self refreshOutgoingAvatarWithImage:[LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage];
        }
    }];
}

//上传顾客信息
- (void)setCurrentClientInfoWithCompletion:(void (^)(BOOL success))completion
{
    //1. 如果用户自定义了头像，上传
    //2. 上传用户的其他自定义信息
    [self setClientAvartarIfNeededComplete:^{
        if ([LGChatViewConfig sharedConfig].clientInfo) {
            [LGServiceToViewInterface setClientInfoWithDictionary:[LGChatViewConfig sharedConfig].clientInfo completion:^(BOOL success, NSError *error) {
                completion(success);
            }];
        } else {
            completion(true);
        }
    }];
}

- (void)setClientAvartarIfNeededComplete:(void(^)(void))completion {
    if ([LGChatViewConfig sharedConfig].shouldUploadOutgoingAvartar) {
        [LGServiceToViewInterface uploadClientAvatar:[LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage completion:^(NSString *avatarUrl, NSError *error) {
            NSMutableDictionary *userInfo = [[LGChatViewConfig sharedConfig].clientInfo mutableCopy];
            if (!userInfo) {
                userInfo = [NSMutableDictionary new];
            }
            [userInfo setObject:avatarUrl forKey:@"avatar"];
            [LGChatViewConfig sharedConfig].shouldUploadOutgoingAvartar = NO;
            completion();
        }];
    } else {
        completion();
    }
}


- (void)updateChatTitleWithAgent:(LGAgent *)agent state:(LGState)state {
    LGChatAgentStatus agentStatus = [self getAgentStatus:agent];
    NSString *viewTitle = @"";
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didScheduleClientWithViewTitle:agentStatus:)]) {
            switch (state) {
                case LGStateAllocatingAgent:
                    viewTitle = [LGBundleUtil localizedStringForKey:@"wait_agent"];
                    agentStatus = LGChatAgentStatusNone;
                    break;
                case LGStateUnallocatedAgent:
                case LGStateBlacklisted:
                case LGStateOffline:
                    viewTitle = [LGBundleUtil localizedStringForKey:@"no_agent_title"];
                    agentStatus = LGChatAgentStatusNone;
                    break;
                case LGStateQueueing:
                    viewTitle = [LGBundleUtil localizedStringForKey:@"waiting_title"];
                    agentStatus = LGChatAgentStatusNone;
                    break;
                case LGStateAllocatedAgent:
                    viewTitle = agent.nickname;
                    break;
                case LGStateInitialized:
                case LGStateUninitialized:
                    viewTitle = [LGBundleUtil localizedStringForKey:@"wait_agent"];
                    agentStatus = LGChatAgentStatusNone;
                    break;
            }
            
            [self.delegate didScheduleClientWithViewTitle:viewTitle agentStatus:agentStatus];
        }
        
        if ([self.delegate respondsToSelector:@selector(changeNavReightBtnWithAgentType:hidden:)]) {
            NSString *agentType = @"";
            switch (agent.privilege) {
                case LGAgentPrivilegeAdmin:
                    agentType = @"admin";
                    break;
                case LGAgentPrivilegeAgent:
                    agentType = @"agent";
                    break;
                case LGAgentPrivilegeBot:
                    agentType = @"bot";
                    break;
                case LGAgentPrivilegeNone:
                    agentType = @"";
                    break;
                default:
                    break;
            }
            
            [self.delegate changeNavReightBtnWithAgentType:agentType hidden:(state != LGStateAllocatedAgent)];
        }
    }
}

- (LGChatAgentStatus)getAgentStatus:(LGAgent *)agent {
    if (!agent.isOnline) {
        return LGChatAgentStatusOffLine;
    }
    
    if (agent.privilege == LGAgentPrivilegeBot) {
        return LGChatAgentStatusOnDuty;
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

- (void)addNoAgentTip {
    if (!self.noAgentTipShowed && ![LGServiceToViewInterface isBlacklisted] && [LGServiceToViewInterface waitingInQueuePosition] == 0) {
        self.noAgentTipShowed = YES;
        [self addTipCellModelWithTips:[LGBundleUtil localizedStringForKey:@"no_agent_tips"] enableLinesDisplay:true];
    }
}

#pragma mark - LGServiceToViewInterfaceDelegate

// 进入页面从服务器或者数据库获取历史消息
- (void)didReceiveHistoryMessages:(NSArray *)messages {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didGetHistoryMessagesWithCommitTableAdjustment:)]) {
            __weak typeof(self) wself = self;
            [self.delegate didGetHistoryMessagesWithCommitTableAdjustment:^{
                __strong typeof (wself) sself = wself;
                if (messages.count > 0) {
                    [sself saveToCellModelsWithMessages:messages isInsertAtFirstIndex:true];
                    [sself.delegate reloadChatTableView];
                }
            }];
        }
    }
}

// 分配客服成功
- (void)didScheduleResult:(LGClientOnlineResult)onLineResult withResultMessages:(NSArray<LGMessage *> *)message {
    
    // 让UI显示历史消息成功了再发送
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.cacheTextArr.count > 0) {
            for (NSString *text in self.cacheTextArr) {
                [self sendTextMessageWithContent:text];
            }
            [self.cacheTextArr removeAllObjects];
        }
        
        if (self.cacheImageArr.count > 0) {
            for (UIImage *image in self.cacheImageArr) {
                [self sendImageMessageWithImage:image];
            }
            [self.cacheImageArr removeAllObjects];
        }
        
        if (self.cacheFilePathArr.count > 0) {
            for (NSString *path in self.cacheFilePathArr) {
                [self sendVoiceMessageWithAMRFilePath:path];
            }
            [self.cacheFilePathArr removeAllObjects];
        }
    });
}

#pragma mark - handle message
- (void)handleEventMessage:(LGEventMessage *)eventMessage {
    // 撤回消息 
    if (eventMessage.eventType == LGChatEventTypeWithdrawMsg) {
        [self.cellModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id<LGCellModelProtocol> cellModel = obj;
            NSString *cellMessageId =  [cellModel getCellMessageId];
            if (cellMessageId && cellMessageId.integerValue == eventMessage.messageId.integerValue) {
                [LGManager updateMessageWithDrawWithId:cellMessageId withIsWithDraw:YES];
                [self.cellModels removeObjectAtIndex:idx];
                [self.delegate removeCellAtIndex:idx];
                
                LGTipsCellModel *cellModel = [[LGTipsCellModel alloc] initCellModelWithTips:@"客服撤回了一条消息" cellWidth:self.chatViewWidth enableLinesDisplay:NO];
                [self.cellModels insertObject:cellModel atIndex:idx];
                [self.delegate insertCellAtCurrentIndex:idx modelCount:1];
            }

        }];
        
    }
    NSString *tipString = eventMessage.tipString;
    if (tipString.length > 0) {
        if ([self respondsToSelector:@selector(didReceiveTipsContent:)]) {
            [self didReceiveTipsContent:tipString showLines:NO];
        }
    }
    
    // 客服邀请评价、客服主动结束会话
    if (eventMessage.eventType == LGChatEventTypeInviteEvaluation) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(showEvaluationAlertView)] && [self.delegate respondsToSelector:@selector(isChatRecording)]) {
                if (![self.delegate isChatRecording]) {
                    [self.delegate showEvaluationAlertView];
                }
            }
        }
    }
}

- (void)handleVisualMessages:(NSArray *)messages {
    NSInteger newCellCount = [self saveToCellModelsWithMessages:messages isInsertAtFirstIndex:false];
    [self playReceivedMessageSound];
    BOOL needsResort = NO;

    // find earliest message
    LGBaseMessage *earliest = [messages reduce:[messages firstObject] step:^id(LGBaseMessage *current, LGBaseMessage *element) {
        return [[earliest date] compare:[element date]] == NSOrderedDescending ? element : current;
    }];
    
    if ([[earliest date] compare:[[self.cellModels lastObject] getCellDate]] == NSOrderedAscending) {
        needsResort = YES;
    }
    
    if (needsResort) {
        [self.cellModels sortUsingComparator:^NSComparisonResult(id<LGCellModelProtocol>  _Nonnull obj1,  id<LGCellModelProtocol> _Nonnull obj2) {
            return [[obj1 getCellDate] compare:[obj2 getCellDate]];
        }];
    }
    [self.delegate insertCellAtBottomForModelCount:newCellCount];
}

- (void)onceLoadHistoryAndRefreshWithSendMsg:(NSString *)message{
//    [self afterClientOnline];
    [self sendTextMessageWithContent:message];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDate *msgDate = [NSDate date];
        [LGManager getDatabaseHistoryMessagesWithMsgDate:msgDate messagesNumber:0 result:^(NSArray<LGMessage *> *messagesArray) {
            if (self.cellModels) {
                [self.cellModels removeAllObjects];
            }
            NSArray *receivedMessages = [self convertToChatViewMessageWithLGMessages:messagesArray];
            if (receivedMessages) {
                [self saveToCellModelsWithMessages:receivedMessages isInsertAtFirstIndex: NO];
                [self.delegate reloadChatTableView];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [self scrollToBottom];
//                });
            }
            
        }];
    });

}

#pragma mark - viewInface delegate

- (void)didReceiveNewMessages:(NSArray *)messages {
    if (messages.count == 1 && [[messages firstObject] isKindOfClass:[LGEventMessage class]]) { // Event message
        LGEventMessage *eventMessage = (LGEventMessage *)[messages firstObject];
        [self handleEventMessage:eventMessage];
    } else {
        [self handleVisualMessages:messages];
    }
    
    //通知界面收到了消息
    BOOL isRefreshView = true;
    if (![LGChatViewConfig sharedConfig].enableEventDispaly && [[messages firstObject] isKindOfClass:[LGEventMessage class]]) {
        isRefreshView = false;
    } else {
        if (messages.count == 1 && [[messages firstObject] isKindOfClass:[LGEventMessage class]]) {
            LGEventMessage *eventMessage = [messages firstObject];
            if (eventMessage.eventType == LGChatEventTypeAgentInputting) {
                isRefreshView = false;
            }
        }
    }
    
    //若收到 socket 消息为机器人
    if ([messages count] == 1 && [[messages firstObject] isKindOfClass:[LGBotAnswerMessage class]]) {
        //调用强制转人工方法
        if ([((LGBotAnswerMessage *)[messages firstObject]).subType isEqualToString:@"redirect"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self forceRedirectToHumanAgent];
            });
        }
        //渲染手动转人工
        if ([((LGBotAnswerMessage *)[messages firstObject]).subType isEqualToString:@"manual_redirect"]) {
            [self addTipCellModelWithType:LGTipTypeBotManualRedirect];
        }
    }
    //等待 0.1 秒，等待 tableView 更新后再滑动到底部，优化体验
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate && isRefreshView) {
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage)]) {
                [self.delegate didReceiveMessage];
            }
        }
    });
}

- (void)didReceiveTipsContent:(NSString *)tipsContent {
    [self didReceiveTipsContent:tipsContent showLines:YES];
}

- (void)didReceiveTipsContent:(NSString *)tipsContent showLines:(BOOL)show {
    LGTipsCellModel *cellModel = [[LGTipsCellModel alloc] initCellModelWithTips:tipsContent cellWidth:self.chatViewWidth enableLinesDisplay:show];
    [self addCellModelAfterReceivedWithCellModel:cellModel];
}

- (void)addCellModelAfterReceivedWithCellModel:(id<LGCellModelProtocol>)cellModel {
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self didReceiveMessageWithCellModel:cellModel];
}

- (void)didReceiveMessageWithCellModel:(id<LGCellModelProtocol>)cellModel {
    [self addCellModelAndReloadTableViewWithModel:cellModel];
    [self playReceivedMessageSound];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage)]) {
            [self.delegate didReceiveMessage];
        }
    }
}

- (void)didRedirectWithAgentName:(NSString *)agentName {
    //[self updateChatTitleWithAgent:[LGServiceToViewInterface getCurrentAgent]];
}

- (void)didSendMessageWithNewMessageId:(NSString *)newMessageId
                          oldMessageId:(NSString *)oldMessageId
                        newMessageDate:(NSDate *)newMessageDate
                       replacedContent:(NSString *)replacedContent
                            sendStatus:(LGChatMessageSendStatus)sendStatus
{
    [self playSendedMessageSound];

    if ([LGServiceToViewInterface getCurrentAgentName].length == 0 && self.clientStatus != LGStateAllocatingAgent) {
        [self addNoAgentTip];
    }
    NSInteger index = [self getIndexOfCellWithMessageId:oldMessageId];
    if (index < 0) {
        return;
    }
    id<LGCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
    if ([cellModel respondsToSelector:@selector(updateCellMessageId:)]) {
        [cellModel updateCellMessageId:newMessageId];
    }
    if ([cellModel respondsToSelector:@selector(updateCellSendStatus:)]) {
        [cellModel updateCellSendStatus:sendStatus];
    }
    
    BOOL needSplitLine = NO;
    if (cellModel.getMessageConversionId.length < 1) {
        if ([cellModel respondsToSelector:@selector(updateCellConversionId:)]) {
            [cellModel updateCellConversionId:[LGServiceToViewInterface getCurrentConversationID]];
        }
    } else {
        if (cellModel.getMessageConversionId != [LGServiceToViewInterface getCurrentConversationID]) {
            needSplitLine = YES;
            if ([cellModel respondsToSelector:@selector(updateCellConversionId:)]) {
                [cellModel updateCellConversionId:[LGServiceToViewInterface getCurrentConversationID]];
            }
        }
    }
    if (newMessageDate) {
        [cellModel updateCellMessageDate:newMessageDate];
    }
    if (replacedContent) {
        [cellModel updateSensitiveState:YES cellText:replacedContent];
    }
    
    // 消息发送完成，刷新单行cell
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (needSplitLine) {
            LGSplitLineCellModel *cellModel1 = [[LGSplitLineCellModel alloc] initCellModelWithCellWidth:self.chatViewWidth withConversionDate:newMessageDate];
            [self.cellModels replaceObjectAtIndex:index withObject:cellModel1];
            [self.cellModels addObject:cellModel];
            [self reloadChatTableView];
            [self scrollToBottom];
        } else {
            [self updateCellWithIndex:index needToBottom:YES];
        }
    });
    
    // 将 messageId 保存到 set，用于去重
//    if (![currentViewMessageIdSet containsObject:newMessageId]) {
//        [currentViewMessageIdSet addObject:newMessageId];
//    }
}

#endif

/**
 *  刷新所有的本机用户的头像
 */
- (void)refreshOutgoingAvatarWithImage:(UIImage *)avatarImage {
    NSMutableArray *indexsToReload = [NSMutableArray new];
    for (NSInteger index=0; index<self.cellModels.count; index++) {
        id<LGCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
        if ([cellModel respondsToSelector:@selector(updateOutgoingAvatarImage:)]) {
            [cellModel updateOutgoingAvatarImage:avatarImage];
            [indexsToReload addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
}

- (void)dismissingChatViewController {
    [LGServiceToViewInterface setClientOffline];
}

- (NSString *)getPreviousInputtingText {
#ifdef INCLUDE_LAIGU_SDK
    return [LGServiceToViewInterface getPreviousInputtingText];
#else
    return @"";
#endif
}

- (void)setCurrentInputtingText:(NSString *)inputtingText {
    [LGServiceToViewInterface setCurrentInputtingText:inputtingText];
}

- (void)evaluateBotAnswer:(BOOL)isUseful messageId:(NSString *)messageId {
    /**
     对机器人消息做评价，分两步：
        1、调用评价接口；
        2、生成正在转接的本地消息；
        3、调用强制转接接口；
     */
    [LGServiceToViewInterface evaluateBotMessage:messageId
                                        isUseful:isUseful
                                      completion:^(BOOL success, NSString *text, NSError *error) {
                                          // 根据企业的消息反馈，渲染一条消息气泡
                                          if (text.length > 0) {
                                              [self createLocalTextMessageWithText:text];
                                          }
                                          // 若用户点击「无用」，生成转人工的状态
                                          LGAgent *agent = [LGServiceToViewInterface getCurrentAgent];
                                          if (!isUseful && agent.privilege == LGAgentPrivilegeBot) {
                                              // 生成转人工的状态
                                              [self addTipCellModelWithType:LGTipTypeBotRedirect];
                                          }
                                      }];
    // 改变 botAnswerCellModel 的值
    for (id<LGCellModelProtocol> cellModel in self.cellModels) {
        if ([[cellModel getCellMessageId] isEqualToString:messageId]) {
            if ([cellModel respondsToSelector:@selector(didEvaluate)]) {
                [cellModel didEvaluate];
            }
            
        }
    }
}

/**
 生成本地的消息，不发送网络请求
 */
- (void)createLocalTextMessageWithText:(NSString *)text {
    //text message
    LGTextMessage *textMessage = [[LGTextMessage alloc] initWithContent:text];
    textMessage.fromType = LGChatMessageIncoming;
    
    [self didReceiveNewMessages:@[textMessage]];
    
}

/**
 强制转人工
 */
- (void)forceRedirectToHumanAgent {
    NSString *currentAgentId = [LGServiceToViewInterface getCurrentAgentId];
    [LGServiceToViewInterface setNotScheduledAgentWithAgentId:currentAgentId];
    [self setClientOnline];
    [self removeBotTipCellModels];
    [self reloadChatTableView];
    
}

#pragma mark - lazyload
#ifdef INCLUDE_LAIGU_SDK
- (LGServiceToViewInterface *)serviceToViewInterface {
    if (!_serviceToViewInterface) {
        _serviceToViewInterface = [LGServiceToViewInterface new];
    }
    return _serviceToViewInterface;
}

-(NSMutableArray *)cacheTextArr {
    if (!_cacheTextArr) {
        _cacheTextArr = [NSMutableArray new];
    }
    return _cacheTextArr;
}

-(NSMutableArray *)cacheImageArr {
    if (!_cacheImageArr) {
        _cacheImageArr = [NSMutableArray new];
    }
    return _cacheImageArr;
}

-(NSMutableArray *)cacheFilePathArr {
    if (!_cacheFilePathArr) {
        _cacheFilePathArr = [NSMutableArray new];
    }
    return _cacheFilePathArr;
}

#endif

@end
