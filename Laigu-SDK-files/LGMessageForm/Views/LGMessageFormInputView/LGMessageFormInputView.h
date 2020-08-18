//
//  LGMessageFormInputView.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 16/5/6.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGMessageFormInputModel.h"

@interface LGMessageFormInputView : UIView

- (instancetype)initWithScreenWidth:(CGFloat)screenW andModel:(LGMessageFormInputModel *)model;

- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y;

- (NSString *)getText;

- (UITextView *)findFirstResponderUITextView;

@end
