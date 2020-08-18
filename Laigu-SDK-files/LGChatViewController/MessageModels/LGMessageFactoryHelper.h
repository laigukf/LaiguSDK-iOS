//
//  LGMessageFactoryHelper.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 2016/11/17.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGBaseMessage.h"
#import <LaiGuSDK/LGMessage.h>

@protocol LGMessageFactory <NSObject>

- (LGBaseMessage *)createMessage:(LGMessage *)plainMessage;

@end


@interface LGMessageFactoryHelper : NSObject

+ (id<LGMessageFactory>)factoryWithMessageAction:(LGMessageAction)action contentType:(LGMessageContentType)contenType fromType:(LGMessageFromType)fromType;

@end
