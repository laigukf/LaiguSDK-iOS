//
//  LGWebViewController.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/6/15.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGWebViewController.h"
#import "LGAssetUtil.h"

@interface LGWebViewController()<WKNavigationDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) NSValue *backBarTitleOffset;

@end

@implementation LGWebViewController

- (void)viewDidLoad {
    //xlptodo
    [super viewDidLoad];

    
    self.webView = [WKWebView new];
    self.webView.navigationDelegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.webView.dataDetectorTypes = UIDataDetectorTypeNone; daizqtodo
    
    [self.view addSubview:self.webView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
    
    if (self.url.length > 0) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    } else if (self.contentHTML.length > 0) {
        [self.webView loadHTMLString:self.contentHTML baseURL:nil];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[LGAssetUtil backArrow] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicator];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURLRequest *request = navigationAction.request;
    if (![request.URL.absoluteString isEqualToString:@"about:blank"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.indicator startAnimating];
    
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError * _Nullable error) {
        if (title.length > 0) {
            self.title = title;
        }
    }];
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.indicator stopAnimating];
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self.indicator stopAnimating];
}



- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicator;
}
@end
