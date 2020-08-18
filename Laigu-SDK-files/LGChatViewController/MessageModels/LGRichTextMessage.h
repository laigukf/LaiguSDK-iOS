//
//  LGRichTextMessage.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/6/14.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGBaseMessage.h"

@interface LGRichTextMessage : LGBaseMessage

@property (nonatomic, copy)NSString *thumbnail;
@property (nonatomic, copy)NSString *summary;
@property (nonatomic, copy)NSString *content;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
