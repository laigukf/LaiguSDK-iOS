//
//  LGWebViewController.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/6/15.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface LGWebViewController : UIViewController

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *contentHTML;
@property (nonatomic, strong) WKWebView *webView;

@end
