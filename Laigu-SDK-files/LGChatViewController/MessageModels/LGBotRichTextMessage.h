//
//  LGBotRickTextMessage.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/8/8.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGRichTextMessage.h"

@class LGBotMenuMessage;
@interface LGBotRichTextMessage : LGRichTextMessage

@property (nonatomic, strong) NSNumber *questionId;
@property (nonatomic, assign) BOOL isEvaluated;
@property (nonatomic, copy) NSString *subType;

@property (nonatomic, strong) LGBotMenuMessage *menu;

- (id)initWithDictionary:(NSDictionary *)dictionary ;

@end
