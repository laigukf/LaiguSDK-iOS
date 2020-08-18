//
//  LGPreChatData.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 16/7/6.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import "LGModel.h"

@class LGPreChatMenu,LGPreChatMenuItem,LGPreChatForm,LGPreChatFormItem;

extern NSString *const kCaptchaToken;
extern NSString *const kCaptchaValue;

typedef NS_ENUM(NSUInteger, LGPreChatFormItemInputType) {
    LGPreChatFormItemInputTypeSingleSelection,
    LGPreChatFormItemInputTypeMultipleSelection,
    LGPreChatFormItemInputTypeSingleLineText,
    LGPreChatFormItemInputTypeSingleLineNumberText,
    LGPreChatFormItemInputTypeSingleLineDateText,
    LGPreCHatFormItemInputTypeMultipleLineText,
    LGPreChatFormItemInputTypeCaptcha,
};

@interface LGPreChatData : LGModel

@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSNumber *isUseCapcha;
@property (nonatomic, strong) NSNumber *hasSubmittedForm;
@property (nonatomic, strong) LGPreChatMenu *menu;
@property (nonatomic, strong) LGPreChatForm *form;

@end

@interface LGPreChatMenu : LGModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) NSArray *menuItems;

@end

@interface LGPreChatMenuItem : LGModel

@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *targetKind;
@property (nonatomic, copy) NSString *target;

@end

@interface LGPreChatForm : LGModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) NSArray *formItems;

@end

@interface LGPreChatFormItem : LGModel

@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *filedName;
@property (nonatomic, assign) LGPreChatFormItemInputType type;
@property (nonatomic, strong) NSNumber *isOptional;
@property (nonatomic, strong) NSArray *choices;
@property (nonatomic, strong) NSNumber *isIgnoreReturnCustomer;

@end
