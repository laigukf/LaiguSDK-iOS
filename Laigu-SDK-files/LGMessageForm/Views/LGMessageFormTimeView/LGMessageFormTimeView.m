//
//  LGMessageFormTimeView.m
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/12/8.
//  Copyright © 2020 LaiGu. All rights reserved.
//

#import "LGMessageFormTimeView.h"
#import "LGMessageFormConfig.h"

static CGFloat const kLGMessageFormSpacing   = 16.0;
static CGFloat const kLGMessageFormContentHeigh  = 42.0;

@interface LGMessageFormTimeView() <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UITextField *contentTextField;

@property (nonatomic, strong) UIDatePicker *dataPicker;

@property (nonatomic, strong) UIView *topContentLine;

@property (nonatomic, strong) UIView *bottomContentLine;

@property (nonatomic, strong) LGMessageFormInputModel *inputModel;

@end

@implementation LGMessageFormTimeView

- (instancetype)initWithModel:(LGMessageFormInputModel *)model {
    self = [super init];
    if (self) {
        self.inputModel = model;
        [self initTipLabelWithModel:model];
        [self initContentView];
    }
    return self;
}

- (void)initTipLabelWithModel:(LGMessageFormInputModel *)model {
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.text = model.tip;
    [self refreshTipLabelFrame];
    self.tipLabel.font = [UIFont systemFontOfSize:14];
    self.tipLabel.textColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.tipTextColor;
    
    if (model.isRequired) {
        NSString *text = [NSString stringWithFormat:@"%@%@", self.tipLabel.text, @"*"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedText addAttribute:NSForegroundColorAttributeName value:self.tipLabel.textColor range:NSMakeRange(0, model.tip.length)];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(model.tip.length, 1)];
        self.tipLabel.attributedText = attributedText;
    }
    [self addSubview:self.tipLabel];
}

- (void)initContentView {
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    
    self.topContentLine = [[UIView alloc] init];
    self.topContentLine.backgroundColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.inputTopBottomBorderColor;
    [self.contentView addSubview:self.topContentLine];
    
    self.contentTextField = [[UITextField alloc] init];
    self.contentTextField.textColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.contentTextColor;
    self.contentTextField.backgroundColor = [UIColor whiteColor];
    self.contentTextField.tintColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.inputPlaceholderTextColor;
    self.contentTextField.font = [UIFont systemFontOfSize:14];
    self.contentTextField.placeholder = self.inputModel.placeholder;
    self.contentTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLGMessageFormSpacing, self.contentTextField.frame.size.height)];
    self.contentTextField.leftViewMode = UITextFieldViewModeAlways;
    self.contentTextField.delegate = self;
    self.contentTextField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLGMessageFormSpacing, self.contentTextField.frame.size.height)];
    self.contentTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.contentView addSubview:self.contentTextField];
    
    self.dataPicker = [[UIDatePicker alloc] init];
    self.dataPicker.datePickerMode = UIDatePickerModeDate;
    if (@available(iOS 14.0, *)) {
        self.dataPicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    [self.dataPicker addTarget:self action:@selector(dateChangeValue) forControlEvents:UIControlEventValueChanged];
    self.contentTextField.inputView = self.dataPicker;
    
    self.bottomContentLine = [[UIView alloc] init];
    self.bottomContentLine.backgroundColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.inputTopBottomBorderColor;
    [self.contentView addSubview:self.bottomContentLine];
    [self refreshContentFrame];
}

- (void)refreshTipLabelFrame {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [self.tipLabel sizeToFit];
    self.tipLabel.frame = CGRectMake(kLGMessageFormSpacing, kLGMessageFormSpacing, screenWidth - kLGMessageFormSpacing * 2, self.tipLabel.frame.size.height + kLGMessageFormSpacing / 2);
}

- (void)refreshContentFrame {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.topContentLine.frame = CGRectMake(0, 0, screenWidth, 1.0);
    self.contentTextField.frame = CGRectMake(0, CGRectGetMaxY(self.topContentLine.frame), screenWidth - kLGMessageFormSpacing, kLGMessageFormContentHeigh);
    self.bottomContentLine.frame = CGRectMake(0, CGRectGetMaxY(self.contentTextField.frame), screenWidth, 1.0);
    self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame), screenWidth, CGRectGetMaxY(self.bottomContentLine.frame));
}

- (void)dateChangeValue {
    NSDate *date = self.dataPicker.date;
    NSDateFormatter *dateForm = [[NSDateFormatter alloc]init];
    dateForm.dateFormat =@"yyyy-MM-dd";
    self.contentTextField.text = [dateForm stringFromDate:date];
}

- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y {
    [self refreshTipLabelFrame];
    [self refreshContentFrame];
    
    self.frame = CGRectMake(0, y, screenWidth, CGRectGetMaxY(self.contentView.frame));
}

- (UIView *)findFirstResponderUIView {
    return self;
}

- (id)getContentValue {
    return self.contentTextField.text;
}

#pragma UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self dateChangeValue];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO;
}

@end
