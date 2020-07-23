//
//  LGVisialMessageFactory.h
//  Laigu-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGMessageFactoryHelper.h"

@interface LGVisialMessageFactory : NSObject <LGMessageFactory>

- (LGBaseMessage *)createMessage:(LGMessage *)plainMessage;

@end
