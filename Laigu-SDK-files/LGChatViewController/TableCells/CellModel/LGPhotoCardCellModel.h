//
//  LGPhotoCardCellModel.h
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGCellModelProtocol.h"
#import "LGPhotoCardMessage.h"
#import "LGPhotoCardMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LGPhotoCardCellModel : NSObject <LGCellModelProtocol>

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
 * bubble中的imageView的frame
 */
@property (nonatomic, readonly, assign) CGRect contentImageViewFrame;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 操作目标的Path
 */
@property (nonatomic, readonly, copy) NSString *targetUrl;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readonly, copy) UIImage *avatarImage;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readonly, assign) CGRect bubbleFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readonly, assign) CGRect avatarFrame;

/**
 * @brief 读取照片的指示器的frame
 */
@property (nonatomic, readonly, assign) CGRect loadingIndicatorFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readonly, assign) LGChatCellFromType cellFromType;


/**
 *  根据LGMessage内容来生成cell model
 */
- (LGPhotoCardCellModel *)initCellModelWithMessage:(LGPhotoCardMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<LGCellModelDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
