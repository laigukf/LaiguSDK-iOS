//
//  LGPreChatFormViewModel.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/7/6.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGPreChatFormViewModel.h"
#import "LGChatViewConfig.h"
#import "LGServiceToViewInterface.h"
#import "NSArray+LGFunctional.h"
#import "LGChatViewConfig.h"
#import "LGJsonUtil.h"

@implementation LGPreChatFormViewModel

- (void)requestPreChatServeyDataIfNeed:(void(^)(LGPreChatData *data, NSError *error))block {
    __weak typeof(self) wself = self;
    [LGServiceToViewInterface requestPreChatServeyDataIfNeedCompletion:^(LGPreChatData *data, NSError *error) {
        __strong typeof (wself) sself = wself;
        sself.formData = [self filterFormData:data];
        
        if (data.isUseCapcha.boolValue) {
            LGPreChatFormItem *captchaItem = [LGPreChatFormItem new];
            captchaItem.type = LGPreChatFormItemInputTypeCaptcha;
            captchaItem.displayName = @"验证码";
            captchaItem.isOptional = @(NO);
            captchaItem.filedName = kCaptchaValue;
            data.form.formItems = [data.form.formItems arrayByAddingObject:captchaItem];
        }
        
        block(sself.formData, error);
    }];
}

- (LGPreChatData *)filterFormData:(LGPreChatData *)formData {
    
    if ([formData.menu.status isEqualToString:@"close"] && [formData.form.status isEqualToString:@"close"]) {
        return nil;
    } else {
        NSMutableArray *filteredMenuItens = [NSMutableArray new];
        NSString *groupId = [LGChatViewConfig sharedConfig].scheduledGroupId;
        NSString *agentId = [LGChatViewConfig sharedConfig].scheduledAgentId;
        
        [formData.menu.menuItems enumerateObjectsUsingBlock:^(LGPreChatMenuItem *menuItem, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *target = nil;
            if ([menuItem targetKind]) {
                if ([[menuItem target] isEqualToString:@"group"]) {
                    target = groupId;
                } else if ([[menuItem target] isEqualToString:@"agent"]) {
                    target = agentId;
                }
            }
            if (target) {
                if ([target isEqualToString:menuItem.target]) {
                    [filteredMenuItens addObject:menuItem];
                }
            } else {
                [filteredMenuItens addObject:menuItem];
            }
        }];
        formData.menu.menuItems = filteredMenuItens;
        
        //3.4.2以下的逻辑是  先判断是否提交过 询前表单,如果提交过 再判断收集顾客信息页面 某些选项 是否 有回头客不显示 有 则不显示
        // > 3.4.2 则hasSubmittedForm 失效 默认返回 false , 本地保存 收集顾客信息页面 上次点选的信息  和  后台返回的 哪些选项 选择了回头客 不显示 ,然后最终确定 该页面 显示哪些选项
        // 等于说 本地保存 hasSubmittedForm ,提交过询前表单 就需要保存为真 否则为假  
//        if (formData.hasSubmittedForm.boolValue) {
        if (self.hasSubmittedFormLocalBool) {
            
            NSMutableArray *filteredFormItems = [NSMutableArray new];
            [formData.form.formItems enumerateObjectsUsingBlock:^(LGPreChatFormItem *formItem, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![formItem isIgnoreReturnCustomer].boolValue) {
                    [filteredFormItems addObject:formItem];
                }
            }];
            formData.form.formItems = filteredFormItems;
        }
    }
    
    return formData;
}

- (void)setValue:(id)value forFieldIndex:(NSInteger)fieldIndex {
    if (value) {
        [self.filledFieldValueDic setObject:value forKey:@(fieldIndex)];
    } else {
        [self.filledFieldValueDic removeObjectForKey:@(fieldIndex)];
    }
//    LGInfo(@"valued changed: %@", self.filledFieldValue);
}

- (UIKeyboardType)keyboardtypeForType:(NSString *)type {
    static dispatch_once_t onceToken;
    static NSDictionary *map;
    dispatch_once(&onceToken, ^{
        map = @{
                @"qq":@(UIKeyboardTypeNumberPad),
                @"weibo":@(UIKeyboardTypeDefault),
                @"age":@(UIKeyboardTypeNumberPad),
                @"email":@(UIKeyboardTypeEmailAddress),
                @"tel":@(UIKeyboardTypePhonePad),
                @"wechat":@(UIKeyboardTypeDefault),
                @"name":@(UIKeyboardTypeDefault),
                @"gender":@(-1),
                };
    });
    
    return (UIKeyboardType)[map[type] intValue];
}

- (NSMutableDictionary *)filledFieldValueDic {
    if (!_filledFieldValueDic) {
        _filledFieldValueDic = [NSMutableDictionary new];
    }
    return _filledFieldValueDic;
}

- (id)valueForFieldIndex:(NSInteger)fieldIndex {
//    NSString *filedName = [(LGPreChatFormItem *)self.formData.form.formItems[fieldIndex] filedName];
    return [self.filledFieldValueDic objectForKey:@(fieldIndex)];
}

- (void)requestCaptchaComplete:(void(^)(UIImage *image))block {
    if (block == nil) return;
    
    __weak typeof(self) wself = self;
    [LGServiceToViewInterface getCaptchaWithURLComplete:^(NSString *token, NSString *url) {
        if (url.length > 0) {
            [LGServiceToViewInterface downloadMediaWithUrlString:url progress:nil completion:^(NSData *mediaData, NSError *error) {
                if (mediaData && mediaData.length > 0) {
                    UIImage *image = [UIImage imageWithData:mediaData];
                    __strong typeof (wself) sself = wself;
                    if (token) {
                        sself.captchaToken = token;
                    }
                    block(image);
                }
            }];
        }
    }];
}

- (NSArray *)submitFormCompletion:(void(^)(id response, NSError *e))block {
    NSArray *unsatisfiedIndexs = [self auditInputs:self.filledFieldValueDic];
    
    if (unsatisfiedIndexs.count == 0) {
        //replace params key to server defined filed name
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        for (NSNumber *key in self.filledFieldValueDic.allKeys) {
            LGPreChatFormItem *item = self.formData.form.formItems[key.integerValue];
            params[item.filedName] = self.filledFieldValueDic[key];
        }
        
        params[kCaptchaToken] = self.captchaToken;
        
        [LGServiceToViewInterface submitPreChatForm:params completion:^(id r, NSError *e) {
            
            if (e.userInfo[@"com.alamofire.serialization.response.error.data"]) {
                NSData *data = e.userInfo[@"com.alamofire.serialization.response.error.data"];
                NSDictionary *info = [LGJsonUtil createWithJSONString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                if ([info isKindOfClass:[NSDictionary class]]) {
                    if (info[@"captcha_needed"]) {
                        e = [NSError errorWithDomain:info[@"message"] code:0 userInfo:nil];
                    }
                }
            }
            
            return block(r, e);
        }];
    } else {
        block(nil, [NSError errorWithDomain:@"请填写完整标记部分的内容" code:1 userInfo:nil]);
    }
    
    return unsatisfiedIndexs;
}

- (NSArray *)auditInputs:(NSDictionary *)inputs {
    NSMutableArray *unsatisfiedIndexs = [NSMutableArray new];
    
    int i = 0;
    for (LGPreChatFormItem *item in self.formData.form.formItems) {
        if (!item.isOptional.boolValue) {
            if (![self.filledFieldValueDic objectForKey:@(i)]) {
                [unsatisfiedIndexs addObject:@(i)];
            }
        }
        i ++;
    }
    
    return unsatisfiedIndexs;
}

//xlp
- (BOOL)hasSubmittedFormLocalBool{
    _hasSubmittedFormLocalBool = [[NSUserDefaults standardUserDefaults]boolForKey:@"hasSubmittedFormLocalBool"];
    return _hasSubmittedFormLocalBool;
}

@end
