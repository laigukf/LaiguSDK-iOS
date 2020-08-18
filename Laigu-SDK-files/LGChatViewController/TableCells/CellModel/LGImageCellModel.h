//
//  LGImageCellModel.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/29.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGCellModelProtocol.h"
#import "LGImageMessage.h"

/**
 * 聊天气泡和其中的图片较大一边的水平间距
 */
static CGFloat const kLGCellBubbleToImageHorizontalLargerSpacing = 14.0;
/**
 * 聊天气泡和其中的图片较小一边的水平间距
 */
static CGFloat const kLGCellBubbleToImageHorizontalSmallerSpacing = 8.0;
/**
 * 聊天气泡和其中的图片垂直间距
 */
static CGFloat const kLGCellBubbleToImageVerticalSpacing = 8.0;

/**
 * LGImageCellModel定义了图片消息的基本类型数据，包括产生cell的内部所有view的显示数据，cell内部元素的frame等
 * @warning LGImageCellModel必须满足LGCellModelProtocol协议
 */
@interface LGImageCellModel : NSObject <LGCellModelProtocol>

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readonly, strong) NSString *messageId;

/**
 * @brief 用户名字，暂时没用
 */
@property (nonatomic, readonly, copy) NSString *userName;

/**
 * @brief 该cellModel的委托对象
 */
@property (nonatomic, weak) id<LGCellModelDelegate> delegate;

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief 图片image(当imagePath不存在时使用)
 */
@property (nonatomic, readonly, strong) UIImage *image;

/**
 * bubble中的imageView的frame，该frame是在关闭bubble mask情况下生效
 */
@property (nonatomic, readonly, assign) CGRect contentImageViewFrame;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readonly, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片 
 */
@property (nonatomic, readonly, copy) UIImage *avatarImage;

/**
 * @brief 聊天气泡的image（该气泡image已经进行了resize）
 */
@property (nonatomic, readonly, copy) UIImage *bubbleImage;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readonly, assign) CGRect bubbleImageFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readonly, assign) CGRect avatarFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readonly, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 读取照片的指示器的frame
 */
@property (nonatomic, readonly, assign) CGRect loadingIndicatorFrame;

/**
 * @brief 发送出错图片的frame
 */
@property (nonatomic, readonly, assign) CGRect sendFailureFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readonly, assign) LGChatCellFromType cellFromType;

/**
 * @brief 消息的发送状态
 */
@property (nonatomic, assign) LGChatMessageSendStatus sendStatus;


- (void)showImageViewerFromRect:(CGRect)rect;


/**
 *  根据LGMessage内容来生成cell model
 */
- (LGImageCellModel *)initCellModelWithMessage:(LGImageMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<LGCellModelDelegate>)delegator;


@end
