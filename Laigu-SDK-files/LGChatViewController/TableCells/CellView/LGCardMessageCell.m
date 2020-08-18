//
//  LGCardMessageCell.m
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 2020/5/25.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import "LGCardMessageCell.h"
#import "LGCardCellModel.h"
#import "LGChatViewConfig.h"
#import "LGImageUtil.h"
#import <LaiGuSDK/LGManager.h>
#import "LGRadioGroup.h"
#import "NSString+Regular.h"
#import "LGToast.h"
#import "LGTipsCell.h"
#import "NSString+Name.h"


@interface LGCardMessageCell ()<UITextFieldDelegate>
{
    UIImageView *avatarImageView;
    UIImageView *bubbleImageView;
    UIButton *sendBtn;
    UIActivityIndicatorView *sendingIndicator;
    UIImageView *failureImageView;
    LGRadioGroup *checkGroup;
    LGCardCellModel *cellModel;
    NSMutableDictionary *resultDic;
}

@property (nonatomic, strong) NSArray *cardData;

@property (strong, nonatomic) UIDatePicker *dataPicker;

@property (strong, nonatomic) UITextField *currentField;

@end

@implementation LGCardMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        resultDic = [[NSMutableDictionary alloc] init];
        //初始化头像
        avatarImageView = [[UIImageView alloc] init];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:avatarImageView];
        
        
        //初始化indicator
        sendingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        sendingIndicator.hidden = YES;
        [self.contentView addSubview:sendingIndicator];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    if (![model isKindOfClass:[LGCardCellModel class]]) {
        NSAssert(NO, @"传给LGCardCell的Model类型不正确");
        return ;
    }
    cellModel = (LGCardCellModel *)model;
    //初始化气泡
    if (!bubbleImageView) {
        bubbleImageView = [[UIImageView alloc] init];
        bubbleImageView.userInteractionEnabled = true;
        [self.contentView addSubview:bubbleImageView];
    }

    
    //刷新头像
    if (cellModel.avatarImage) {
        avatarImageView.image = cellModel.avatarImage;
    }
    avatarImageView.frame = cellModel.avatarFrame;
    if ([LGChatViewConfig sharedConfig].enableRoundAvatar) {
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.cornerRadius = cellModel.avatarFrame.size.width/2;
    }
    
    //刷新气泡
    bubbleImageView.image = cellModel.bubbleImage;
    bubbleImageView.frame = cellModel.bubbleImageFrame;
    
    // 刷新card
    __block CGFloat cellHeight = 0;
    sendBtn = [[UIButton alloc] init];
        
    sendBtn.backgroundColor = [UIColor colorWithRed:118/255.0 green:163/255.0 blue:214/255.0 alpha:1.0f];
    sendBtn.userInteractionEnabled = YES;
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [sendBtn.layer setCornerRadius:5];
    [sendBtn addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
    [bubbleImageView addSubview:sendBtn];

    sendBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:@[
    [NSLayoutConstraint constraintWithItem:sendBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:-20],
    [NSLayoutConstraint constraintWithItem:sendBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:20],
    [NSLayoutConstraint constraintWithItem:sendBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeRight multiplier:1 constant:-20],
    [NSLayoutConstraint constraintWithItem:sendBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40],
    
    ]];
    
    NSArray *cardItems = cellModel.cardData;
    self.cardData = cellModel.cardData;
//    __weak typeof(self) weakSelf = self;
    
    [cardItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LGCardInfo *info = (LGCardInfo *)obj;
        if (info.cardType == LGMessageCardTypeText || info.cardType == LGMessageCardTypeDateTime) {
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"请输入 %@", info.label];
            [bubbleImageView addSubview:label];
            UITextField *inputText = [[UITextField alloc] init];
            inputText.backgroundColor = UIColor.whiteColor;
            inputText.delegate = self;
            inputText.tag = info.contentId;
            [bubbleImageView addSubview:inputText];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [self addConstraints:@[
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeTop multiplier:1 constant:cellHeight + 10],
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:20],
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeRight multiplier:1 constant:-20],
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30],
            
            ]];
            
            inputText.translatesAutoresizingMaskIntoConstraints = NO;
            [self addConstraints:@[
            [NSLayoutConstraint constraintWithItem:inputText attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeTop multiplier:1 constant:cellHeight + 45],
            [NSLayoutConstraint constraintWithItem:inputText attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:20],
            [NSLayoutConstraint constraintWithItem:inputText attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeRight multiplier:1 constant:-20],
            [NSLayoutConstraint constraintWithItem:inputText attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30],
            
            ]];
            cellHeight += 70;
            if ([info.name isEqualToString:@"tel"]) {
                inputText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            }else if ([info.name isEqualToString:@"qq"]) {
                inputText.keyboardType = UIKeyboardTypeNumberPad;
            }else if ([info.name isEqualToString:@"email"]) {
                inputText.keyboardType = UIKeyboardTypeEmailAddress;
            }
            if (info.cardType == LGMessageCardTypeDateTime) {
                UIDatePicker *datePicker = [[UIDatePicker alloc] init];
                datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
                [datePicker setDate:[NSDate date] animated:YES];
                [datePicker setMaximumDate:[NSDate date]];
                [datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
                datePicker.datePickerMode = UIDatePickerModeDateAndTime;

                self.dataPicker = datePicker;
                inputText.inputView = datePicker;
                self.currentField = inputText;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";   
                NSString *dateStr = [dateFormatter  stringFromDate:[NSDate date]];
                inputText.text = dateStr;
                if (inputText.text) {
                    [resultDic setValue:inputText.text forKey:info.name];
                }

            }
        }else if (info.cardType == LGMessageCardTypeRadio || info.cardType == LGMessageCardTypeCheckbox) {
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"请选择 %@", info.label];
            [bubbleImageView addSubview:label];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [self addConstraints:@[
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeTop multiplier:1 constant:cellHeight + 10],
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:20],
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:bubbleImageView attribute:NSLayoutAttributeRight multiplier:1 constant:-20],
            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30],
            
            ]];
            NSArray *metaArr = info.metaData;
            __block NSMutableArray *radioMutableArr = [NSMutableArray array];
            [metaArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LGCardInfoMeta *meta = obj;
                
                LGRadioButton *radioBtn = [[LGRadioButton alloc] initWithFrame:CGRectMake(0, 35*idx, 200, 30)];
                radioBtn.selectedAll = NO;
                radioBtn.text = meta.name;
                radioBtn.value = info.name;
                radioBtn.textColor = [UIColor grayColor];
                [radioMutableArr addObject:radioBtn];
            }];
            checkGroup = [[LGRadioGroup alloc] initWithFrame:CGRectMake(20, cellHeight + 40, 200,  35*metaArr.count) WithCheckBtns:radioMutableArr];
            checkGroup.isCheck = info.cardType == LGMessageCardTypeCheckbox ? YES : NO;
            checkGroup.tag = info.contentId;
            bubbleImageView.userInteractionEnabled = YES;
            [bubbleImageView addSubview:checkGroup];

            cellHeight += 40 + 35*metaArr.count;
        }
    }];
    
    
    //刷新indicator
    sendingIndicator.hidden = true;
    [sendingIndicator stopAnimating];
    if (cellModel.sendStatus == LGChatMessageSendStatusSending && cellModel.cellFromType == LGChatCellOutgoing) {
        sendingIndicator.hidden = false;
        sendingIndicator.frame = cellModel.sendingIndicatorFrame;
        [sendingIndicator startAnimating];
    }
        
    //刷新出错图片
    failureImageView.hidden = true;
    if (cellModel.sendStatus == LGChatMessageSendStatusFailure) {
        failureImageView.hidden = false;
        failureImageView.frame = cellModel.sendFailureFrame;
    }
}

#pragma mark - textFiled
- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    for (LGCardInfo *info in self.cardData) {
        if (textField.tag == info.contentId) {
            if (resultDic[info.name]) {
                [resultDic removeObjectForKey:info.name];
            }
            if ([info.name isEqualToString:@"tel"]) {
                NSString *text = textField.text;
                if (![text isTelNumber] || !text) {
                    textField.layer.borderColor = UIColor.redColor.CGColor;
                    textField.layer.borderWidth = 1.0;
                    [LGToast showToast:@"手机号格式不对,请重新输入" duration:2.0 window:[[UIApplication sharedApplication].windows lastObject]];
                    return;
                }
            }else if ([info.name isEqualToString:@"qq"]) {
                NSString *text = textField.text;
                if (![text isQQ] || !text) {
                    textField.layer.borderColor = UIColor.redColor.CGColor;
                    textField.layer.borderWidth = 1.0;
                    [LGToast showToast:@"QQ格式不对,请重新输入" duration:2.0 window:[[UIApplication sharedApplication].windows lastObject]];
                    return;
                }
            }else {
                NSString *text = textField.text;
                if (!text || text.length == 0) {
                    textField.layer.borderColor = UIColor.redColor.CGColor;
                    textField.layer.borderWidth = 1.0;
                    [LGToast showToast:@"不能为空" duration:2.0 window:[[UIApplication sharedApplication].windows lastObject]];
                    return;
                }

            }
            textField.layer.borderWidth = 0.0;
            textField.layer.borderColor = UIColor.blackColor.CGColor;
            [resultDic setValue:textField.text forKey:info.name];
        }
    }
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    return NO;
//}


- (void)dateChange:(UIDatePicker *)datePicker {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSString *dateStr = [dateFormatter  stringFromDate:datePicker.date];
    
    self.currentField.text = dateStr;
}

- (void)sendClick:(UIButton *)sender{
        
    for (LGCardInfo *info in self.cardData) {
    
        if (info.cardType == LGMessageCardTypeRadio || info.cardType == LGMessageCardTypeCheckbox) {
            LGRadioGroup *group = (LGRadioGroup *)[bubbleImageView viewWithTag:info.contentId];
            if (group.isCheck) {
                if (group.selectValueArr && group.selectValueArr.count > 0) {
                    [resultDic setValue:group.selectTextArr forKey:group.selectValueArr.firstObject];
                }
            }else{
                if (group.selectValue) {
                    [resultDic setValue:group.selectText forKey:group.selectValue];
                }
            }
        }
    }
    
    if (!resultDic || resultDic.allValues.count != self.cardData.count) {
        [LGToast showToast:@"请完善后再提交" duration:2.0 window:[[UIApplication sharedApplication].windows lastObject]];
        return;
    }
    

    NSMutableDictionary *newClientInfo = [NSMutableDictionary dictionary];
    [newClientInfo setValue:resultDic forKey:@"attrs"];

    __weak typeof(self) weakSelf = self;

    [LGManager updateCardInfo:newClientInfo completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.chatCellDelegate deleteCell:weakSelf withTipMsg:@"提交成功" enableLinesDisplay:YES];
            }else{
                [self.chatCellDelegate deleteCell:weakSelf withTipMsg:@"提交失败" enableLinesDisplay:YES];
            }
            if (self->bubbleImageView) {
                [self->bubbleImageView removeFromSuperview];
                self->bubbleImageView = nil;
            }
            if (self->resultDic) {
                [self->resultDic removeAllObjects];
            }
        });
    }];
    
}

@end
