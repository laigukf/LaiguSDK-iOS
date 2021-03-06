//
//  LGRadioButton.h
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 2020/5/25.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QRadioButtonDelegate;

@interface LGRadioButton : UIButton
 
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) NSString *selectedImgName;
@property (nonatomic, strong) NSString *unSelectedImgName;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) BOOL selectedAll;

@end

NS_ASSUME_NONNULL_END
