//
//  LGMessageFormViewStyle.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 16/5/11.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGMessageFormViewStyle.h"
#import "LGAssetUtil.h"
#import "LGMessageFormViewStyleBlue.h"
#import "LGMessageFormViewStyleGreen.h"
#import "LGMessageFormViewStyleDark.h"

@implementation LGMessageFormViewStyle

+ (instancetype)createWithStyle:(LGMessageFormViewStyleType)type {
    switch (type) {
        case LGMessageFormViewStyleTypeBlue:
            return [LGMessageFormViewStyleBlue new];
        case LGMessageFormViewStyleTypeGreen:
            return [LGMessageFormViewStyleGreen new];
        case LGMessageFormViewStyleTypeDark:
            return [LGMessageFormViewStyleDark new];
        default:
            return [LGMessageFormViewStyle new];
    }
}

+ (instancetype)defaultStyle {
    return [self createWithStyle:(LGMessageFormViewStyleTypeDefault)];
}

+ (instancetype)blueStyle {
    return [self createWithStyle:(LGMessageFormViewStyleTypeBlue)];
}

+ (instancetype)darkStyle {
    return [self createWithStyle:(LGMessageFormViewStyleTypeDark)];
}

+ (instancetype)greenStyle {
    return [self createWithStyle:(LGMessageFormViewStyleTypeGreen)];
}

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor            = nil;//[UIColor colorWithHexString:LGBlueColor];
        self.navBarTintColor        = nil;//[UIColor whiteColor];
        self.navTitleColor          = nil;//[UIColor whiteColor];
        
        self.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:247 / 255.0 alpha:1];
        self.introTextColor = [UIColor colorWithRed:118 / 255.0 green:125 / 255.0 blue:133 / 255.0 alpha:1];
        self.inputTipTextColor = [UIColor colorWithRed:173 / 255.0 green:178 / 255.0 blue:187 / 255.0 alpha:1];
        self.inputPlaceholderTextColor = [UIColor colorWithRed:198 / 255.0 green:203 / 255.0 blue:208 / 255.0 alpha:1];
        self.inputTextColor = [UIColor colorWithRed:90 / 255.0 green:105 / 255.0 blue:120 / 255.0 alpha:1];
        self.inputTopBottomBorderColor = [UIColor colorWithRed:0.81 green:0.82 blue:0.84 alpha:1.00];
        self.addPictureTextColor = [UIColor colorWithRed:173 / 255.0 green:178 / 255.0 blue:187 / 255.0 alpha:1];
        self.deleteImage = [UIImage imageNamed:[LGAssetUtil resourceWithName:@"LGMessageFormDeleteIcon"]];
        self.addImage = [UIImage imageNamed:[LGAssetUtil resourceWithName:@"LGMessageFormAddIcon"]];
    }
    return self;
}

@end
