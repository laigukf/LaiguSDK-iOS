//
//  LGCustomizedUIText.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/4/26.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LGUITextKey) {
    
    LGUITextKeyMessageInputPlaceholder,
    LGUITextKeyMessageNoMoreMessage,
    LGUITextKeyMessageNewMessaegArrived,
    LGUITextKeyMessageConfirmResend,
    LGUITextKeyMessageRefreshFail,
    LGUITextKeyMessageLoadHistoryMessageFail,
    
    LGUITextKeyRecordButtonBegin,
    LGUITextKeyRecordButtonEnd,
    LGUITextKeyRecordButtonCancel,
    LGUITextKeyRecordDurationTooShort,
    LGUITextKeyRecordSwipeUpToCancel,
    LGUITextKeyRecordReleaseToCancel,
    LGUITextKeyRecordFail,
    
    LGUITextKeyImageSelectFromImageRoll,
    LGUITextKeyImageSelectCamera,
    LGUITextKeyImageSaveFail,
    LGUITextKeyImageSaveComplete,
    LGUITextKeyImageSave,
    
    LGUITextKeyTextCopy,
    LGUITextKeyTextCopied,
    
    LGUITextKeyNetworkTrafficJam,
    LGUITextKeyDefaultAssistantName,
    
    LGUITextKeyNoAgentTitle,
    LGUITextKeySchedulingAgent,
    LGUITextKeyNoAgentTip,
    
    LGUITextKeyContactMakeCall,
    LGUITextKeyContactSendSMS,
    LGUITextKeyContactSendEmail,
    
    LGUITextKeyOpenLinkWithSafari,
    
    LGUITextKeyRequestEvaluation,
    LGUITextKeyRequestRedirectAgent,
    
    LGUITextKeyFileDownloadOverdue,
    LGUITextKeyFileDownloadCancel,
    LGUITextKeyFileDownloadDownloading,
    LGUITextKeyFileDownloadComplete,
    LGUITextKeyFileDownloadFail,
    
    LGUITextKeyBlacklistMessageRejected,
    LGUITextKeyBlacklistListedInBlacklist,
    
    LGUITextKeyNoAgentAvailableTip,
    LGUITextKeyBotRedirectTip,
    LGUITextKeyBotManualRedirectTip,
    
    LGUITextKeyClientIsOnlining,
    LGUITextKeySendTooFast,
    
    //询前表单
    LGUITextKeyPreChatListTitle,
    LGUITextKeyPreChatFormTitle,
    LGUITextKeyPreChatFormMultipleSelectionLabel,
    LGUITextKeyPreChatFormBlankAlertLabel,
    
    LGUITextKeyQueuePosition,
    
    //pull refresh
    LGUITextKeyPullRefreshNormal,
    LGUITextKeyPullRfreshTriggered,
};

@interface LGCustomizedUIText : NSObject

///自定义 UI 中的文案
+ (void)setCustomiedTextForKey:(LGUITextKey)key text:(NSString *)string;

+ (void)reset;

+ (NSString *)customiedTextForBundleKey:(NSString *)bundleKey;

@end
