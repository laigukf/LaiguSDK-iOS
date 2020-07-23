//
//  LGBotWebViewController.h
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/8/9.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGWebViewController.h"

@class LGBotRichTextMessage;
@interface LGBotWebViewController : LGWebViewController

@property (nonatomic, strong)LGBotRichTextMessage *message;
@property (nonatomic, copy) void(^botEvaluateDidTapUseful)(NSString *);
@property (nonatomic, copy) void(^botEvaluateDidTapUseless)(NSString *);

@end
