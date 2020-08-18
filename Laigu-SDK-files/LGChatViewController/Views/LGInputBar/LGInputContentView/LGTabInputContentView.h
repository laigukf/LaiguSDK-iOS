//
//  LGTabInputContentView.h
//  Laigu
//
//  Created by zhangshunxing on 16/4/14.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGInputContentView.h"
#import "LAIGU_HPGrowingTextView.h"

@interface LGTabInputContentView : LGInputContentView <UITextFieldDelegate>

@property (strong, nonatomic) LAIGU_HPGrowingTextView *textField;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setupButtons;

@end
