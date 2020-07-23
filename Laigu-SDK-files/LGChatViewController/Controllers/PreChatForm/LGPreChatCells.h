//
//  LGPreChatCells.h
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/7/7.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+LGLayout.h"
#import "NSArray+LGFunctional.h"
#import <LaiGuSDK/LaiguSDK.h>

#define TextFieldLimit 100

@interface LGPrechatSingleLineTextCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, copy) void(^valueChangedAction)(NSString *);
@property (nonatomic, strong) UITextField *textField;

@end


#pragma mark -

@interface LGPreChatMultiLineTextCell : UITableViewCell

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, copy) void(^heightChanged)(CGFloat);

@end

#pragma mark -

@interface LGPreChatSelectionCell : UITableViewCell

@end

#pragma mark -

@interface LGPreChatCaptchaCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *refreshCapchaButton;
@property (nonatomic, copy) void(^valueChangedAction)(NSString *);
@property (nonatomic, copy) void(^loadCaptchaAction)(UIButton *);

@end

#pragma mark -

@interface LGPreChatSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) LGPreChatFormItem *formItem;
@property (nonatomic, strong) UILabel *titelLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *isOptionalLabel;
@property (nonatomic, assign) BOOL shouldMark;

- (void)setStatus:(BOOL)isReady;

@end

#pragma mark -


