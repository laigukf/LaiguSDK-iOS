//
//  LGBundleUtil.h
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/11/16.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGBundleUtil : NSBundle

+ (NSBundle *)assetBundle;

+ (NSString *)localizedStringForKey:(NSString *)key;

@end
