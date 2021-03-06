//
//  LGImageMessageCell.m
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGImageMessageCell.h"
#import "LGImageCellModel.h"
#import "LGChatFileUtil.h"
#import "LGImageUtil.h"
#import "LGChatViewConfig.h"
#import "LGBundleUtil.h"

@implementation LGImageMessageCell {
    UIImageView *avatarImageView;
    UIImageView *bubbleImageView;
    UIImageView *bubbleContentImageView;
    UIActivityIndicatorView *sendingIndicator;
    UIImageView *failureImageView;
    UIActivityIndicatorView *loadingIndicator;
    
    LGImageCellModel *cellModel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化头像
        avatarImageView = [[UIImageView alloc] init];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:avatarImageView];
        //初始化气泡
        bubbleImageView = [[UIImageView alloc] init];
        UILongPressGestureRecognizer *longPressBubbleGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBubbleView:)];
        [bubbleImageView addGestureRecognizer:longPressBubbleGesture];
        bubbleImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleTapped)];
        [bubbleImageView addGestureRecognizer:tapGesture];
        
        [self.contentView addSubview:bubbleImageView];
        
        //初始化contentImageView
        bubbleContentImageView = [[UIImageView alloc] init];
        bubbleContentImageView.layer.masksToBounds = true;
        bubbleContentImageView.layer.cornerRadius = 6.0;
        [bubbleImageView addSubview:bubbleContentImageView];
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
        //初始化加载数据的indicator
        loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingIndicator.hidden = YES;
        [bubbleImageView addSubview:loadingIndicator];
    }
    return self;
}

#pragma LGChatCellProtocol
- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    if (![model isKindOfClass:[LGImageCellModel class]]) {
        NSAssert(NO, @"传给LGImageMessageCell的Model类型不正确");
        return ;
    }
    cellModel = (LGImageCellModel *)model;

    //刷新头像
    if (cellModel.avatarImage) {
        avatarImageView.image = cellModel.avatarImage;
    }
    avatarImageView.frame = cellModel.avatarFrame;
    if ([LGChatViewConfig sharedConfig].enableRoundAvatar) {
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.cornerRadius = cellModel.avatarFrame.size.width / 2;
    }
    
    //刷新气泡
    bubbleImageView.frame = cellModel.bubbleImageFrame;
    
    //消息图片
    loadingIndicator.frame = cellModel.loadingIndicatorFrame;
    if (cellModel.image) {
        if ([LGChatViewConfig sharedConfig].enableMessageImageMask) {
            bubbleImageView.image = cellModel.image;
            [LGImageUtil makeMaskView:bubbleImageView withImage:cellModel.bubbleImage];
        } else {
            bubbleImageView.userInteractionEnabled = true;
            bubbleImageView.image = cellModel.bubbleImage;
            bubbleContentImageView.image = cellModel.image;
            bubbleContentImageView.frame = cellModel.contentImageViewFrame;
        }
        
        loadingIndicator.hidden = true;
        [loadingIndicator stopAnimating];
    } else {
        bubbleImageView.image = cellModel.bubbleImage;
        loadingIndicator.hidden = false;
        [loadingIndicator startAnimating];
    }
    
    //刷新indicator
    sendingIndicator.hidden = true;
    [sendingIndicator stopAnimating];
    if (cellModel.sendStatus == LGChatMessageSendStatusSending && cellModel.cellFromType == LGChatCellOutgoing) {
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


#pragma 长按事件
- (void)longPressBubbleView:(id)sender {
    if (((UILongPressGestureRecognizer*)sender).state == UIGestureRecognizerStateBegan) {
        [self showMenuControllerInView:self targetRect:bubbleImageView.frame menuItemsName:@{@"imageCopy" : bubbleImageView.image}];
    }
}

#pragma 单击气泡
- (void)bubbleTapped {
    
    UIView *view = self;
    
    while (![view isKindOfClass:[UITableView class]]) {
        view = view.superview;
    }
    
    [cellModel showImageViewerFromRect:[bubbleImageView.superview convertRect:bubbleImageView.frame toView:[UIApplication sharedApplication].keyWindow]];
}

#pragma 点击发送失败消息 重新发送事件
- (void)tapFailImage:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[LGBundleUtil localizedStringForKey:@"retry_send_message"] message:nil delegate:self cancelButtonTitle:[LGBundleUtil localizedStringForKey:@"alert_view_cancel"] otherButtonTitles:[LGBundleUtil localizedStringForKey:@"alert_view_confirm"], nil];
    [alertView show];
}

#pragma UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.chatCellDelegate resendMessageInCell:self resendData:@{@"image" : bubbleImageView.image}];
    }
}



@end
