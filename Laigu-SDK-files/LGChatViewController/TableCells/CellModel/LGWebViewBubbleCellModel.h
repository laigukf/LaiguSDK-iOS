//
//  LGLGWebViewBubbleCellModel.h
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGCellModelProtocol.h"

@class LGRichTextMessage;
@interface LGWebViewBubbleCellModel : NSObject <LGCellModelProtocol>

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) CGFloat(^cellHeight)(void);
@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);

@property (nonatomic, assign) CGFloat cachedWetViewHeight;

- (void)bind;

- (id)initCellModelWithMessage:(LGRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator;

@end
