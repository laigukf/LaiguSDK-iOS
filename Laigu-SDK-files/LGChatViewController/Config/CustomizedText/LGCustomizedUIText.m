//
//  LGCustomizedUIText.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/4/26.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGCustomizedUIText.h"

static NSDictionary * keyTextMap;
static NSMutableDictionary * customizedTextMap;

@implementation LGCustomizedUIText

+ (void)load {
    keyTextMap = @{
        @(LGUITextKeyMessageInputPlaceholder) : @"new_message",
        @(LGUITextKeyMessageNoMoreMessage) : @"no_more_messages",
        @(LGUITextKeyMessageNewMessaegArrived) : @"display_new_message",
        @(LGUITextKeyMessageConfirmResend) : @"retry_send_message",
        @(LGUITextKeyMessageRefreshFail) : @"cannot_refresh",
        @(LGUITextKeyMessageLoadHistoryMessageFail) : @"load_history_message_error",
        
        @(LGUITextKeyRecordButtonBegin) : @"record_speak",
        @(LGUITextKeyRecordButtonEnd) : @"record_end",
        @(LGUITextKeyRecordButtonCancel) : @"cancel",
        @(LGUITextKeyRecordDurationTooShort) : @"recode_time_too_short",
        @(LGUITextKeyRecordSwipeUpToCancel) : @"record_cancel_swipe",
        @(LGUITextKeyRecordReleaseToCancel) : @"record_cancel_realse",
        @(LGUITextKeyRecordFail) : @"record_error",
        
        @(LGUITextKeyImageSelectFromImageRoll) : @"select_gallery",
        @(LGUITextKeyImageSelectCamera) : @"select_camera",
        @(LGUITextKeyImageSaveFail) : @"save_photo_error",
        @(LGUITextKeyImageSaveComplete) : @"save_photo_success",
        @(LGUITextKeyImageSave) : @"save_photo",
        
        @(LGUITextKeyTextCopy) : @"save_text",
        @(LGUITextKeyTextCopied) : @"save_text_success",
        
        @(LGUITextKeyNetworkTrafficJam) : @"network_jam",
        
        @(LGUITextKeyDefaultAssistantName) : @"default_assistant",
        
        @(LGUITextKeyNoAgentTitle) : @"no_agent_title",
        @(LGUITextKeySchedulingAgent) : @"wait_agent",
        @(LGUITextKeyNoAgentTip) : @"no_agent_tips",
        
        @(LGUITextKeyContactMakeCall) : @"make_call_to",
        @(LGUITextKeyContactSendSMS) : @"send_message_to",
        @(LGUITextKeyContactSendEmail) : @"make_email_to",
        
        @(LGUITextKeyOpenLinkWithSafari) : @"open_url_by_safari",
        
        @(LGUITextKeyRequestEvaluation) : @"laigu_evaluation_sheet",
        
        @(LGUITextKeyRequestRedirectAgent) : @"laigu_redirect_sheet",
        
        @(LGUITextKeyNoAgentAvailableTip) : @"reply_tip_text",
        @(LGUITextKeyBotRedirectTip) : @"bot_redirect_tip_text",
        @(LGUITextKeyBotManualRedirectTip) : @"bot_manual_redirect_tip_text",
        
        @(LGUITextKeyFileDownloadOverdue) : @"file_download_file_is_expired",
        @(LGUITextKeyFileDownloadCancel) : @"file_download_canceld",
        @(LGUITextKeyFileDownloadFail) : @"file_download_failed",
        @(LGUITextKeyFileDownloadDownloading) : @"file_download_downloading",
        @(LGUITextKeyFileDownloadComplete) : @"file_download_complete",
        
        @(LGUITextKeyBlacklistMessageRejected) : @"message_tips_send_message_fail_listed_in_black_list",
        @(LGUITextKeyBlacklistListedInBlacklist) : @"message_tips_online_failed_listed_in_black_list",
        
        @(LGUITextKeyClientIsOnlining) : @"cannot_text_client_is_onlining",
        @(LGUITextKeySendTooFast) : @"send_to_fast",
        
        @(LGUITextKeyPreChatListTitle) : @"pre_chat_list_title",
        @(LGUITextKeyPreChatFormTitle) : @"pre_chat_form_title",
        @(LGUITextKeyPreChatFormMultipleSelectionLabel) : @"pre_chat_form_mutiple_selection_label",
        @(LGUITextKeyPreChatFormBlankAlertLabel) : @"pre_chat_form_black_alert_label",
        
        @(LGUITextKeyPullRefreshNormal) : @"pull_refresh_normal",
        @(LGUITextKeyPullRfreshTriggered) : @"pull_refresh_triggered"
        };
    
    
    customizedTextMap = [NSMutableDictionary new];
}

+ (void)setCustomiedTextForKey:(LGUITextKey)key text:(NSString *)string {
    if (string.length == 0) {
        return;
    }
    
    [customizedTextMap setObject:string forKey:[keyTextMap objectForKey:@(key)]];
}

+ (void)reset {
    [customizedTextMap removeAllObjects];
}

+ (NSString *)customiedTextForBundleKey:(NSString *)bundleKey {
    return [customizedTextMap objectForKey:bundleKey];
}

@end
