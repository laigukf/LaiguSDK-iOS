//
//  LGRadioGroup.h
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 2020/5/26.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGRadioButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface LGRadioGroup : UIView

@property (nonatomic, copy) NSString *selectText;
@property (nonatomic, copy) NSString *selectValue;
@property (nonatomic, strong) NSMutableArray *selectTextArr;
@property (nonatomic, strong) NSMutableArray *selectValueArr;
@property (nonatomic,assign) BOOL isCheck;

- (id)initWithFrame:(CGRect)frame WithCheckBtns:(NSArray*)checkBtns;

@end

NS_ASSUME_NONNULL_END
