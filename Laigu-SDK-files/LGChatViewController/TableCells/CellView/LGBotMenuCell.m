//
//  LGBotMenuCell.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 16/4/27.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGBotMenuCell.h"
#import "LGChatFileUtil.h"
#import "LGChatViewConfig.h"
#import "LGBundleUtil.h"
#import "LGBotMenuCellModel.h"
#import "LAIGU_TTTAttributedLabel.h"
#import "LGBundleUtil.h"

static const NSInteger kLGBotMenuCellSelectedUrlActionSheetTag = 2000;
static const NSInteger kLGBotMenuCellSelectedNumberActionSheetTag = 2001;
static const NSInteger kLGBotMenuCellSelectedEmailActionSheetTag = 2002;

@interface LGBotMenuCell() <LAIGU_TTTAttributedLabelDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@end

@implementation LGBotMenuCell  {
    UIImageView *avatarImageView;
    UILabel *textLabel;
    UIImageView *bubbleImageView;
    UIActivityIndicatorView *sendingIndicator;
    UIImageView *failureImageView;
    NSMutableArray *menuButtons;
    UILabel *replyTipLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化头像
        avatarImageView = [[UIImageView alloc] init];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:avatarImageView];
        //初始化气泡
        bubbleImageView = [[UIImageView alloc] init];
        bubbleImageView.userInteractionEnabled = true;
        UILongPressGestureRecognizer *longPressBubbleGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBubbleView:)];
        [bubbleImageView addGestureRecognizer:longPressBubbleGesture];
        [self.contentView addSubview:bubbleImageView];
        //初始化文字
//        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
//            textLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//            textLabel.delegate = self;
//        } else {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
//            textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//#pragma clang diagnostic pop
//        }
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];

        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.userInteractionEnabled = true;
        textLabel.backgroundColor = [UIColor clearColor];
        [bubbleImageView addSubview:textLabel];
        //初始化indicator
        sendingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        sendingIndicator.hidden = YES;
        [self.contentView addSubview:sendingIndicator];
        //初始化出错image
        failureImageView = [[UIImageView alloc] initWithImage:[LGChatViewConfig sharedConfig].messageSendFailureImage];
        UITapGestureRecognizer *tapFailureImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFailImage:)];
        failureImageView.userInteractionEnabled = true;
        [failureImageView addGestureRecognizer:tapFailureImageGesture];
        [self.contentView addSubview:failureImageView];
        // 初始化 menu button 数组
        menuButtons = [NSMutableArray new];
        // 初始化 reply tip label
        replyTipLabel = [UILabel new];
        replyTipLabel.textColor = [UIColor colorWithWhite:.6 alpha:1];
        replyTipLabel.text = kLGBotMenuTipText;
        replyTipLabel.textAlignment = NSTextAlignmentLeft;
        replyTipLabel.font = [UIFont systemFontOfSize:kLGBotMenuReplyTipSize];
        replyTipLabel.hidden = false;
        [bubbleImageView addSubview:replyTipLabel];
    }
    return self;
}

#pragma LGChatCellProtocol
- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    if (![model isKindOfClass:[LGBotMenuCellModel class]]) {
        NSAssert(NO, @"传给 LGBotMenuCellModel 的 Model 类型不正确");
        return ;
    }
    LGBotMenuCellModel *cellModel = (LGBotMenuCellModel *)model;
    
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
    
    //刷新indicator
    sendingIndicator.hidden = true;
    [sendingIndicator stopAnimating];
    if (cellModel.sendStatus == LGChatMessageSendStatusSending && cellModel.cellFromType == LGChatCellOutgoing) {
        sendingIndicator.hidden = false;
        sendingIndicator.frame = cellModel.sendingIndicatorFrame;
        [sendingIndicator startAnimating];
    }
    
    //刷新聊天文字
    textLabel.frame = cellModel.textLabelFrame;
    if ([textLabel isKindOfClass:[TTTAttributedLabel class]]) {
        textLabel.attributedText = cellModel.cellText;
    } else {
        textLabel.attributedText = cellModel.cellText;
    }
    
//    //获取文字中的可选中的元素
//    if (cellModel.numberRangeDic.count > 0) {
//        NSString *longestKey = @"";
//        for (NSString *key in cellModel.numberRangeDic.allKeys) {
//            //找到最长的key
//            if (key.length > longestKey.length) {
//                longestKey = key;
//            }
//        }
//        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
//            [textLabel addLinkToPhoneNumber:longestKey withRange:[cellModel.numberRangeDic[longestKey] rangeValue]];
//        }
//    }
//    if (cellModel.linkNumberRangeDic.count > 0) {
//        NSString *longestKey = @"";
//        for (NSString *key in cellModel.linkNumberRangeDic.allKeys) {
//            //找到最长的key
//            if (key.length > longestKey.length) {
//                longestKey = key;
//            }
//        }
//        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
//            [textLabel addLinkToURL:[NSURL URLWithString:longestKey] withRange:[cellModel.linkNumberRangeDic[longestKey] rangeValue]];
//        }
//    }
//    if (cellModel.emailNumberRangeDic.count > 0) {
//        NSString *longestKey = @"";
//        for (NSString *key in cellModel.emailNumberRangeDic.allKeys) {
//            //找到最长的key
//            if (key.length > longestKey.length) {
//                longestKey = key;
//            }
//        }
//        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
//            [textLabel addLinkToTransitInformation:@{@"email" : longestKey} withRange:[cellModel.emailNumberRangeDic[longestKey] rangeValue]];
//        }
//    }
    
    //刷新出错图片
    failureImageView.hidden = true;
    if (cellModel.sendStatus == LGChatMessageSendStatusFailure) {
        failureImageView.hidden = false;
        failureImageView.frame = cellModel.sendFailureFrame;
    }
    
    // 重置 menu buttons
    NSInteger menuNum = [cellModel.menuTitles count];
    for (UIButton *btn in menuButtons) {
        [btn removeFromSuperview];
    }
    menuButtons = [NSMutableArray new];
    for (NSInteger i = 0; i < menuNum; i++) {
        UIButton *menuButton = [UIButton new];
        menuButton.frame = [[cellModel.menuFrames objectAtIndex:i] CGRectValue];
        [menuButton setTitle:[cellModel.menuTitles objectAtIndex:i] forState:UIControlStateNormal];
        [menuButton setTitleColor:[LGChatViewConfig sharedConfig].chatViewStyle.btnTextColor forState:UIControlStateNormal];
        menuButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [menuButton addTarget:self action:@selector(tapMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
        menuButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        menuButton.titleLabel.numberOfLines = 0;
        menuButton.titleLabel.font = [UIFont systemFontOfSize:kLGBotMenuTextSize];
        [menuButtons addObject:menuButton];
        [bubbleImageView addSubview:menuButton];
    }
    
    // 刷新 reply tip label
    if (menuNum > 0) {
        replyTipLabel.hidden = false;
        replyTipLabel.frame = cellModel.replyTipLabelFrame;
    }
}

#pragma TTTAttributedLabelDelegate 点击事件
- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithPhoneNumber:(NSString *)phoneNumber
                atPoint:(CGPoint)point {
    [self showMenueController];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:phoneNumber delegate:self cancelButtonTitle:[LGBundleUtil localizedStringForKey:@"alert_view_cancel"] destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"%@%@", [LGBundleUtil localizedStringForKey:@"make_call_to"], phoneNumber], [NSString stringWithFormat:@"%@%@", [LGBundleUtil localizedStringForKey:@"send_message_to"], phoneNumber], [LGBundleUtil localizedStringForKey:@"save_text"], nil];
    sheet.tag = kLGBotMenuCellSelectedNumberActionSheetTag;
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:[LGBundleUtil localizedStringForKey:@"alert_view_cancel"] destructiveButtonTitle:nil otherButtonTitles:[LGBundleUtil localizedStringForKey:@"open_url_by_safari"], [LGBundleUtil localizedStringForKey:@"save_text"], nil];
    sheet.tag = kLGBotMenuCellSelectedUrlActionSheetTag;
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    if (!components[@"email"]) {
        return ;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:components[@"email"] delegate:self cancelButtonTitle:[LGBundleUtil localizedStringForKey:@"alert_view_cancel"] destructiveButtonTitle:nil otherButtonTitles:[LGBundleUtil localizedStringForKey:@"make_email_to"], [LGBundleUtil localizedStringForKey:@"save_text"], nil];
    sheet.tag = kLGBotMenuCellSelectedEmailActionSheetTag;
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:LGChatViewKeyboardResignFirstResponderNotification object:nil];
    switch (actionSheet.tag) {
        case kLGBotMenuCellSelectedNumberActionSheetTag: {
            switch (buttonIndex) {
                case 0:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", actionSheet.title]]];
                    break;
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", actionSheet.title]]];
                    break;
                case 2:
                    [UIPasteboard generalPasteboard].string = actionSheet.title;
                    break;
                default:
                    break;
            }
            break;
        }
        case kLGBotMenuCellSelectedUrlActionSheetTag: {
            switch (buttonIndex) {
                case 0: {
                    if ([actionSheet.title rangeOfString:@"://"].location == NSNotFound) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", actionSheet.title]]];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
                    }
                    break;
                }
                case 1:
                    [UIPasteboard generalPasteboard].string = actionSheet.title;
                    break;
                default:
                    break;
            }
            break;
        }
        case kLGBotMenuCellSelectedEmailActionSheetTag: {
            switch (buttonIndex) {
                case 0: {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", actionSheet.title]]];
                    break;
                }
                case 1:
                    [UIPasteboard generalPasteboard].string = actionSheet.title;
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    //通知界面点击了消息
    if (self.chatCellDelegate) {
        if ([self.chatCellDelegate respondsToSelector:@selector(didSelectMessageInCell:messageContent:selectedContent:)]) {
            [self.chatCellDelegate didSelectMessageInCell:self messageContent:self.textLabel.text selectedContent:actionSheet.title];
        }
    }
}

#pragma 长按事件
- (void)longPressBubbleView:(id)sender {
    if (((UILongPressGestureRecognizer*)sender).state == UIGestureRecognizerStateBegan) {
        [self showMenueController];
    }
}

- (void)showMenueController {
    [self showMenuControllerInView:self targetRect:bubbleImageView.frame menuItemsName:@{@"textCopy" : textLabel.text}];
    
}

#pragma 点击发送失败消息 重新发送事件
- (void)tapFailImage:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"重新发送吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.chatCellDelegate resendMessageInCell:self resendData:@{@"text" : textLabel.text}];
    }
}

#pragma 点击 menu 事件
- (void)tapMenuBtn:(UIButton *)menuBtn{
    NSString *didTapMenuText = menuBtn.titleLabel.text;
    if ([self.chatCellDelegate respondsToSelector:@selector(didTapMenuWithText:)]) {
        [self.chatCellDelegate didTapMenuWithText:didTapMenuText];
    }
}



@end

