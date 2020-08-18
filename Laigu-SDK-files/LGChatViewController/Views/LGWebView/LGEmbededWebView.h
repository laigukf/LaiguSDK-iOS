//
//  LGEmbededWebView.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/9/5.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface LGEmbededWebView : WKWebView

@property (nonatomic, copy)void(^loadComplete)(CGFloat);
@property (nonatomic, copy)void(^tappedLink)(NSURL *);

- (void)loadHTML:(NSString *)html WithCompletion:(void(^)(CGFloat))block;

@end
