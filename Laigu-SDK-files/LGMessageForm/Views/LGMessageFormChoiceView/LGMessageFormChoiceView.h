//
//  LGMessageFormChoiceView.h
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/12/7.
//  Copyright © 2020 LaiGu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGMessageFormInputModel.h"
#import "LGMessageFormBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LGMessageFormChoiceView : LGMessageFormBaseView

- (instancetype)initWithModel:(LGMessageFormInputModel *)model;

@end

@interface LGMessageFormChoiceItem : UIView

- (instancetype)initWithItemContent:(NSString *)content;

- (void)refreshFrame;

/**
 * 当前是否处于选中状态
 */
@property (nonatomic, assign) BOOL isChoice;

/**
 * 获取item的内容
 */
- (NSString *)getItemValue;

@end

NS_ASSUME_NONNULL_END
