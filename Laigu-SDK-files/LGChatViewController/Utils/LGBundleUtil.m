//
//  LGBundleUtil.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/11/16.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import "LGBundleUtil.h"
#import "LGChatViewController.h"
#import "LGChatFileUtil.h"
#import "LGCustomizedUIText.h"

@implementation LGBundleUtil

+ (NSBundle *)assetBundle
{
//    NSString *bundleResourcePath = [NSBundle mainBundle].resourcePath;
    NSString *bundleResourcePath = [NSBundle bundleForClass:[LGChatViewController class]].resourcePath;
    NSString *assetPath = [bundleResourcePath stringByAppendingPathComponent:@"LGChatViewAsset.bundle"];
    return [NSBundle bundleWithPath:assetPath];
}

+ (NSString *)localizedStringForKey:(NSString *)key
{
    NSBundle *bundle = [LGBundleUtil assetBundle];
    
    NSString *string = [LGCustomizedUIText customiedTextForBundleKey:key] ?: [bundle localizedStringForKey:key value:nil table:@"LGChatViewController"];
    
    return string;
}

@end
