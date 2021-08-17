//
//  LGImageCellModel.m
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGImageCellModel.h"
#import "LGChatBaseCell.h"
#import "LGImageMessageCell.h"
#import "LGChatViewConfig.h"
#import "LGImageUtil.h"
#import "LGServiceToViewInterface.h"
#import "LGImageViewerViewController.h"
#import "UIViewController+LGHieriachy.h"
#ifndef INCLUDE_LAIGU_SDK
#import "UIImageView+WebCache.h"
#endif
@interface LGImageCellModel()

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readwrite, strong) NSString *messageId;

/**
 * @brief 用户名字，暂时没用
 */
@property (nonatomic, readwrite, copy) NSString *userName;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 图片path
 */
//@property (nonatomic, readwrite, copy) NSString *imagePath;

/**
 * @brief 图片image(当imagePath不存在时使用)
 */
@property (nonatomic, readwrite, strong) UIImage *image;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 聊天气泡的image（该气泡image已经进行了resize）
 */
@property (nonatomic, readwrite, copy) UIImage *bubbleImage;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleImageFrame;

/**
 * bubble中的imageView的frame，该frame是在关闭bubble mask情况下生效
 */
@property (nonatomic, readwrite, assign) CGRect contentImageViewFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 读取照片的指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect loadingIndicatorFrame;

/**
 * @brief 发送出错图片的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendFailureFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) LGChatCellFromType cellFromType;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

@end

@implementation LGImageCellModel

#pragma initialize
/**
 *  根据LGMessage内容来生成cell model
 */
- (LGImageCellModel *)initCellModelWithMessage:(LGImageMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<LGCellModelDelegate>)delegator{
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.delegate = delegator;
        self.messageId = message.messageId;
        self.conversionId = message.conversionId;
        self.sendStatus = message.sendStatus;
        self.date = message.date;
        self.avatarPath = @"";
        self.cellHeight = 44.0;
        if (message.userAvatarImage) {
            self.avatarImage = message.userAvatarImage;
        } else if (message.userAvatarPath.length > 0) {
            self.avatarPath = message.userAvatarPath;
            //这里使用来鼓接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_LAIGU_SDK
            [LGServiceToViewInterface downloadMediaWithUrlString:message.userAvatarPath progress:^(float progress) {
            } completion:^(NSData *mediaData, NSError *error) {
                if (mediaData && !error) {
                    self.avatarImage = [UIImage imageWithData:mediaData];
                } else {
                    self.avatarImage = message.fromType == LGChatMessageIncoming ? [LGChatViewConfig sharedConfig].incomingDefaultAvatarImage : [LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#else
            __block UIImageView *tempImageView = [UIImageView new];
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.userAvatarPath] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                self.avatarImage = tempImageView.image.copy;
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#endif
        } else {
            self.avatarImage = [LGChatViewConfig sharedConfig].incomingDefaultAvatarImage;
            if (message.fromType == LGChatMessageOutgoing) {
                self.avatarImage = [LGChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
            }
        }
        
        //内容图片
        self.image = message.image;
        if (!message.image) {
            if (message.imagePath.length > 0) {
                
                //默认cell高度为图片显示的最大高度
                self.cellHeight = cellWidth / 2;
                
//                [self setModelsWithContentImage:[LGChatViewConfig sharedConfig].incomingBubbleImage cellFromType:message.fromType cellWidth:cellWidth];
                
                //这里使用来鼓接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_LAIGU_SDK
                [LGServiceToViewInterface downloadMediaWithUrlString:message.imagePath progress:^(float progress) {
                } completion:^(NSData *mediaData, NSError *error) {
                    if (mediaData && !error) {
                        self.image = [UIImage imageWithData:mediaData];
                        [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                    } else {
                        self.image = [LGChatViewConfig sharedConfig].imageLoadErrorImage;
                        [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                    }
                    if (self.delegate) {
                        if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                            [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                        }
                    }
                }];
#else
                //非来鼓SDK用户，使用了SDWebImage来做图片缓存
                __block UIImageView *tempImageView = [[UIImageView alloc] init];
                [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.imagePath] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                    if (image) {
                        self.image = tempImageView.image.copy;
                        [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                    } else {
                        self.image = [LGChatViewConfig sharedConfig].imageLoadErrorImage;
                        [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                    }
                    if (self.delegate) {
                        if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                            [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                        }
                    }
                }];
#endif
            } else {
                self.image = [LGChatViewConfig sharedConfig].imageLoadErrorImage;
                [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
            }
        } else {
            [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
        }
        
    }
    return self;
}

//根据气泡中的图片生成其他model
- (void)setModelsWithContentImage:(UIImage *)contentImage
                          cellFromType:(LGChatMessageFromType)cellFromType
                        cellWidth:(CGFloat)cellWidth
{
    //限定图片的最大直径
    CGFloat maxBubbleDiameter = ceil(cellWidth / 2);  //限定图片的最大直径
    CGSize contentImageSize = contentImage ? contentImage.size : CGSizeMake(20, 20);
    
    //先限定图片宽度来计算高度
    CGFloat imageWidth = contentImageSize.width < maxBubbleDiameter ? contentImageSize.width : maxBubbleDiameter;
    CGFloat imageHeight = ceil(contentImageSize.height / contentImageSize.width * imageWidth);
    //判断如果气泡高度计算结果超过图片的最大直径，则限制高度
    if (imageHeight > maxBubbleDiameter) {
        imageHeight = maxBubbleDiameter;
        imageWidth = ceil(contentImageSize.width / contentImageSize.height * imageHeight);
    }
    
    //根据消息的来源，进行处理
    UIImage *bubbleImage = [LGChatViewConfig sharedConfig].incomingBubbleImage;
    if ([LGChatViewConfig sharedConfig].incomingBubbleColor) {
        bubbleImage = [LGImageUtil convertImageColorWithImage:bubbleImage toColor:[LGChatViewConfig sharedConfig].incomingBubbleColor];
    }
    
    if (cellFromType == LGChatMessageOutgoing) {
        //发送出去的消息
        self.cellFromType = LGChatCellOutgoing;
        bubbleImage = [LGChatViewConfig sharedConfig].outgoingBubbleImage;
        if ([LGChatViewConfig sharedConfig].outgoingBubbleColor) {
            bubbleImage = [LGImageUtil convertImageColorWithImage:bubbleImage toColor:[LGChatViewConfig sharedConfig].outgoingBubbleColor];
        }
        //头像的frame
        if ([LGChatViewConfig sharedConfig].enableOutgoingAvatar) {
            self.avatarFrame = CGRectMake(cellWidth-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarDiameter, kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarDiameter, kLGCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        
        //content内容
        self.contentImageViewFrame = CGRectMake(kLGCellBubbleToImageHorizontalSmallerSpacing, kLGCellBubbleToImageVerticalSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(
                                           cellWidth - self.avatarFrame.size.width - kLGCellAvatarToHorizontalEdgeSpacing - kLGCellAvatarToBubbleSpacing - imageWidth - kLGCellBubbleToImageHorizontalSmallerSpacing - kLGCellBubbleToImageHorizontalLargerSpacing,
                                           kLGCellAvatarToVerticalEdgeSpacing,
                                           imageWidth + kLGCellBubbleToImageHorizontalSmallerSpacing + kLGCellBubbleToImageHorizontalLargerSpacing,
                                           imageHeight + kLGCellBubbleToImageVerticalSpacing * 2);
        if ([LGChatViewConfig sharedConfig].enableMessageImageMask) {
            self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarToBubbleSpacing-imageWidth, kLGCellAvatarToVerticalEdgeSpacing, imageWidth, imageHeight);
        }
    } else {
        //收到的消息
        self.cellFromType = LGChatCellIncoming;
        
        //头像的frame
        if ([LGChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kLGCellAvatarToHorizontalEdgeSpacing, kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarDiameter, kLGCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        self.contentImageViewFrame = CGRectMake(kLGCellBubbleToImageHorizontalLargerSpacing, kLGCellBubbleToImageVerticalSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(
                                           self.avatarFrame.origin.x+self.avatarFrame.size.width+kLGCellAvatarToBubbleSpacing,
                                           self.avatarFrame.origin.y,
                                           imageWidth + kLGCellBubbleToImageHorizontalSmallerSpacing + kLGCellBubbleToImageHorizontalLargerSpacing,
                                           imageHeight + kLGCellBubbleToImageVerticalSpacing * 2);
        if ([LGChatViewConfig sharedConfig].enableMessageImageMask) {
            self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kLGCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, imageWidth, imageHeight);
        }
    }
    
    //loading image的indicator
    self.loadingIndicatorFrame = CGRectMake(self.bubbleImageFrame.size.width/2-kLGCellIndicatorDiameter/2, self.bubbleImageFrame.size.height/2-kLGCellIndicatorDiameter/2, kLGCellIndicatorDiameter, kLGCellIndicatorDiameter);
    
    //气泡图片
    self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[LGChatViewConfig sharedConfig].bubbleImageStretchInsets];
    
    //发送消息的indicator的frame
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kLGCellIndicatorDiameter, kLGCellIndicatorDiameter)];
    self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kLGCellBubbleToIndicatorSpacing-indicatorView.frame.size.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-indicatorView.frame.size.height/2, indicatorView.frame.size.width, indicatorView.frame.size.height);
    
    //发送失败的图片frame
    UIImage *failureImage = [LGChatViewConfig sharedConfig].messageSendFailureImage;
    CGSize failureSize = CGSizeMake(ceil(failureImage.size.width * 2 / 3), ceil(failureImage.size.height * 2 / 3));
    self.sendFailureFrame = CGRectMake(self.bubbleImageFrame.origin.x-kLGCellBubbleToIndicatorSpacing-failureSize.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-failureSize.height/2, failureSize.width, failureSize.height);
    
    //计算cell的高度
    self.cellHeight = self.bubbleImageFrame.origin.y + self.bubbleImageFrame.size.height + kLGCellAvatarToVerticalEdgeSpacing;

}


#pragma LGCellModelProtocol
- (CGFloat)getCellHeight {
    return self.cellHeight > 0 ? self.cellHeight : 0;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (LGChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.messageId;
}

- (NSString *)getMessageConversionId {
    return self.conversionId;
}

- (void)updateCellSendStatus:(LGChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.messageId = messageId;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
//    if (self.cellFromType == LGChatCellOutgoing) {
//        //头像的frame
//        if ([LGChatViewConfig sharedConfig].enableOutgoingAvatar) {
//            self.avatarFrame = CGRectMake(cellWidth-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarDiameter, kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarDiameter, kLGCellAvatarDiameter);
//        } else {
//            self.avatarFrame = CGRectMake(0, 0, 0, 0);
//        }
//        //气泡的frame
//        self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kLGCellAvatarToHorizontalEdgeSpacing-kLGCellAvatarToBubbleSpacing-self.bubbleImageFrame.size.width, kLGCellAvatarToVerticalEdgeSpacing, self.bubbleImageFrame.size.width, self.bubbleImageFrame.size.height);
//        //发送指示器的frame
//        self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kLGCellBubbleToIndicatorSpacing-self.sendingIndicatorFrame.size.width, self.sendingIndicatorFrame.origin.y, self.sendingIndicatorFrame.size.width, self.sendingIndicatorFrame.size.height);
//        //发送出错图片的frame
//        self.sendFailureFrame = CGRectMake(self.bubbleImageFrame.origin.x-kLGCellBubbleToIndicatorSpacing-self.sendFailureFrame.size.width, self.sendFailureFrame.origin.y, self.sendFailureFrame.size.width, self.sendFailureFrame.size.height);
//    }
    
    [self setModelsWithContentImage:self.image cellFromType:(LGChatMessageFromType)self.cellFromType cellWidth:cellWidth];
}

- (void)updateOutgoingAvatarImage:(UIImage *)avatarImage {
    if (self.cellFromType == LGChatCellOutgoing) {
        self.avatarImage = avatarImage;
    }
}

- (void)showImageViewerFromRect:(CGRect)rect {
    LGImageViewerViewController *viewerVC = [LGImageViewerViewController new];
    viewerVC.images = @[self.image];
    
    __weak LGImageViewerViewController *wViewerVC = viewerVC;
    [viewerVC setSelection:^(NSUInteger index) {
        __strong LGImageViewerViewController *sViewerVC = wViewerVC;
        [sViewerVC dismiss];
    }];
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [viewerVC showOn:[UIViewController topMostViewController] fromRectArray:[NSArray arrayWithObject:[NSValue valueWithCGRect:rect]]];
}

@end
