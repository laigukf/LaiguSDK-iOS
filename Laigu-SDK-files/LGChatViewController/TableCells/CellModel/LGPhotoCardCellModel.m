//
//  LGPhotoCardCellModel.m
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 ijinmao. All rights reserved.
//

#import "LGPhotoCardCellModel.h"
#import "LGServiceToViewInterface.h"
#import "LGImageUtil.h"
#ifndef INCLUDE_LAIGU_SDK
#import "UIImageView+WebCache.h"
#endif
/**
 * 聊天气泡和其中的图片垂直间距
 */
static CGFloat const kLGCellBubbleToImageSpacing = 12.0;

/**
 * 图片的高宽比,宽4高3
 */
static CGFloat const kLGCellImageRatio = 0.75;

@interface LGPhotoCardCellModel()

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
 * @brief 图片image
 */
@property (nonatomic, readwrite, strong) UIImage *image;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 操作目标的Path
 */
@property (nonatomic, readwrite, copy) NSString *targetUrl;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleFrame;

/**
 * bubble中的imageView的frame
 */
@property (nonatomic, readwrite, assign) CGRect contentImageViewFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 读取照片的指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect loadingIndicatorFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) LGChatCellFromType cellFromType;

@end

@implementation LGPhotoCardCellModel

#pragma initialize
/**
 *  根据LGMessage内容来生成cell model
 */
- (LGPhotoCardCellModel *)initCellModelWithMessage:(LGPhotoCardMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<LGCellModelDelegate>)delegate {
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.delegate = delegate;
        self.messageId = message.messageId;
        self.date = message.date;
        self.targetUrl = message.targetUrl;
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
    return self;
}

//根据气泡中的图片生成其他model
- (void)setModelsWithContentImage:(UIImage *)contentImage
                          cellFromType:(LGChatMessageFromType)cellFromType
                        cellWidth:(CGFloat)cellWidth
{
    //限定图片的最大直径
    CGFloat maxContentImageWide = ceil(cellWidth / 2);  //限定图片的最大直径
    CGSize contentImageSize = contentImage ? contentImage.size : CGSizeMake(40, 30);
    
    //先限定图片宽度来计算高度
    CGFloat imageWidth = contentImageSize.width < maxContentImageWide ? contentImageSize.width : maxContentImageWide;
    CGFloat imageHeight = imageWidth * kLGCellImageRatio;
    
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
        self.contentImageViewFrame = CGRectMake(kLGCellBubbleToImageSpacing, kLGCellBubbleToImageSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleFrame = CGRectMake(
                                           cellWidth - self.avatarFrame.size.width - kLGCellAvatarToHorizontalEdgeSpacing - kLGCellAvatarToBubbleSpacing - imageWidth - 2 * kLGCellBubbleToImageSpacing,
                                           kLGCellAvatarToVerticalEdgeSpacing,
                                           imageWidth + 2 * kLGCellBubbleToImageSpacing,
                                           imageHeight + kLGCellBubbleToImageSpacing * 2);
    } else {
        //收到的消息
        self.cellFromType = LGChatCellIncoming;
        
        //头像的frame
        if ([LGChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kLGCellAvatarToHorizontalEdgeSpacing, kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarDiameter, kLGCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        self.contentImageViewFrame = CGRectMake(kLGCellBubbleToImageSpacing, kLGCellBubbleToImageSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleFrame = CGRectMake(
                                           self.avatarFrame.origin.x+self.avatarFrame.size.width+kLGCellAvatarToBubbleSpacing,
                                           self.avatarFrame.origin.y,
                                           imageWidth + kLGCellBubbleToImageSpacing * 2,
                                           imageHeight + kLGCellBubbleToImageSpacing * 2);
    }
    
    //loading image的indicator
    self.loadingIndicatorFrame = CGRectMake(self.bubbleFrame.size.width/2-kLGCellIndicatorDiameter/2, self.bubbleFrame.size.height/2-kLGCellIndicatorDiameter/2, kLGCellIndicatorDiameter, kLGCellIndicatorDiameter);
    
    //计算cell的高度
    self.cellHeight = self.bubbleFrame.origin.y + self.bubbleFrame.size.height + kLGCellAvatarToVerticalEdgeSpacing;

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
    return [[LGPhotoCardMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.date;
}

- (BOOL)isServiceRelatedCell {
    return NO;
}

- (NSString *)getCellMessageId {
    return self.messageId;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.messageId = messageId;
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


@end

