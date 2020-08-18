//
//  LGImageMessage.h
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/10/30.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGBaseMessage.h"
#import <UIKit/UIKit.h>

@interface LGImageMessage : LGBaseMessage

/** 消息image path */
@property (nonatomic, copy) NSString *imagePath;

/** 消息image */
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithImagePath:(NSString *)imagePath;

- (instancetype)initWithImage:(UIImage *)image;

@end
