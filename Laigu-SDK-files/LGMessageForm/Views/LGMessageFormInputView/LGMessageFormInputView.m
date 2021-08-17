//
//  LGMessageFormInputView.m
//  LaiGuSDK
//
//  Created by bingoogolapple on 16/5/6.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import "LGMessageFormInputView.h"
#import "LGMessageFormTextView.h"
#import "LGMessageFormConfig.h"

static CGFloat const kLGMessageFormSpacing   = 16.0;

@interface LGMessageFormInputView() <UITextFieldDelegate>

@end

@implementation LGMessageFormInputView {
    UILabel *tipLabel;
    UITextField *contentTf;
    LGMessageFormTextView *contentTv;
    UIView *topLine;
    UIView *bottomLine;
}

- (instancetype)initWithScreenWidth:(CGFloat)screenWidth andModel:(LGMessageFormInputModel *)model {
    self = [super init];
    if (self) {
        [self initTipLabelWithModel:model andScreenWidth:screenWidth];
        if (model.isSingleLine) {
            [self initContentTfWidthModel:model andScreenWidth:screenWidth];
        } else {
            [self initContentTvWidthModel:model andScreenWidth:screenWidth];
        }
    }
    return self;
}

- (void)initTipLabelWithModel:(LGMessageFormInputModel *)model andScreenWidth:(CGFloat)screenWidth {
    tipLabel = [[UILabel alloc] init];
    tipLabel.text = model.tip;
    [self refreshTipLabelFrameWithScreenWidth:screenWidth];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.tipTextColor;
    
    if (model.isRequired) {
        NSString *text = [NSString stringWithFormat:@"%@%@", tipLabel.text, @"*"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedText addAttribute:NSForegroundColorAttributeName value:tipLabel.textColor range:NSMakeRange(0, model.tip.length)];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(model.tip.length, 1)];
        tipLabel.attributedText = attributedText;
    }
    [self addSubview:tipLabel];
}

- (void)refreshTipLabelFrameWithScreenWidth:(CGFloat)screenWidth {
    [tipLabel sizeToFit];
    tipLabel.frame = CGRectMake(kLGMessageFormSpacing, kLGMessageFormSpacing, screenWidth - kLGMessageFormSpacing * 2, tipLabel.frame.size.height + kLGMessageFormSpacing / 2);
}

- (void)initContentTfWidthModel:(LGMessageFormInputModel *)model andScreenWidth:(CGFloat)screenWidth {
    contentTf = [[UITextField alloc] init];
    contentTf.textColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.contentTextColor;
    contentTf.backgroundColor = [UIColor whiteColor];
    contentTf.tintColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.inputPlaceholderTextColor;
    contentTf.font = [UIFont systemFontOfSize:14];
    contentTf.placeholder = model.placeholder;
    contentTf.delegate = self;
    contentTf.keyboardType = model.inputModelType == InputModelTypeNumber ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
    contentTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLGMessageFormSpacing, contentTf.frame.size.height)];
    contentTf.leftViewMode = UITextFieldViewModeAlways;
    
    contentTf.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLGMessageFormSpacing, contentTf.frame.size.height)];
    contentTf.rightViewMode = UITextFieldViewModeAlways;
    
    topLine = [[UIView alloc] init];
    topLine.backgroundColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.inputTopBottomBorderColor;
    [contentTf addSubview:topLine];
    bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.inputTopBottomBorderColor;
    [contentTf addSubview:bottomLine];
    
    [self refreshcontentTfFrameWithScreenWidth:screenWidth];
    [self addSubview:contentTf];
}

- (void)refreshcontentTfFrameWithScreenWidth:(CGFloat)screenWidth {
    if (contentTf) {
        contentTf.frame = CGRectMake(0, CGRectGetMaxY(tipLabel.frame), screenWidth, 42);
        topLine.frame = CGRectMake(0, 0, contentTf.frame.size.width, 1);
        bottomLine.frame = CGRectMake(0, contentTf.frame.size.height - 1, contentTf.frame.size.width, 1);
    }
}

- (void)initContentTvWidthModel:(LGMessageFormInputModel *)model andScreenWidth:(CGFloat)screenWidth {
    UIView *contentContainer = [[UIView alloc] init];
    contentContainer.backgroundColor = [UIColor whiteColor];
    
    contentTv = [[LGMessageFormTextView alloc] init];
    contentTv.textColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.contentTextColor;
    contentTv.backgroundColor = [UIColor whiteColor];
    contentTv.tintColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.inputPlaceholderTextColor;
    contentTv.placeholder = model.placeholder;
    contentTf.keyboardType = model.inputModelType == InputModelTypeNumber ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
    contentTv.font = [UIFont systemFontOfSize:14];
    contentTv.showsVerticalScrollIndicator = NO;
    contentTv.text = model.text;
    [contentContainer addSubview:contentTv];
    
    topLine = [[UIView alloc] init];
    topLine.backgroundColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.inputTopBottomBorderColor;
    [contentContainer addSubview:topLine];
    bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.inputTopBottomBorderColor;
    [contentContainer addSubview:bottomLine];
    
    [self refreshcontentTvFrameWithScreenWidth:screenWidth];
    [self addSubview:contentContainer];
}

- (void)refreshcontentTvFrameWithScreenWidth:(CGFloat)screenWidth {
    if (contentTv) {
        UIView *contentContainer = contentTv.superview;
        contentContainer.frame = CGRectMake(0, CGRectGetMaxY(tipLabel.frame), screenWidth, 126);
        contentTv.frame = CGRectMake(kLGMessageFormSpacing - 5, 0, screenWidth - kLGMessageFormSpacing * 2 + 5, contentContainer.frame.size.height);
        topLine.frame = CGRectMake(0, 0, contentContainer.frame.size.width, 1);
        bottomLine.frame = CGRectMake(0, contentContainer.frame.size.height, contentContainer.frame.size.width, 1);
    }
}

- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y {
    [super refreshFrameWithScreenWidth:screenWidth andY:y];
    
    [self refreshTipLabelFrameWithScreenWidth:screenWidth];
    [self refreshcontentTfFrameWithScreenWidth:screenWidth];
    [self refreshcontentTvFrameWithScreenWidth:screenWidth];
    self.frame = CGRectMake(0, y, screenWidth, CGRectGetMaxY(contentTf == nil ? contentTv.superview.frame : contentTf.frame));
}

- (id)getContentValue {
    if (contentTf) {
        return [contentTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    } else {
        return [contentTv.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}


- (UIView *)findFirstResponderUIView {
    if (contentTv && contentTv.isFirstResponder) {
        return self;
    }
    if (contentTf && contentTf.isFirstResponder) {
        return self;
    }
    return nil;
}

#pragma UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
