//
//  LGBotMenuRichCellModel.h
//  LGEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/6/1.
//  Copyright © 2020 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGCellModelProtocol.h"
#import "LGBotMenuMessage.h"


NS_ASSUME_NONNULL_BEGIN

@interface LGBotMenuRichCellModel : NSObject <LGCellModelProtocol>

@property (nonatomic, strong) LGBotMenuMessage *message;

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, copy) NSString *avatarPath;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) CGFloat(^cellHeight)(void);

@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);

@property (nonatomic, assign) CGFloat cachedWetViewHeight;

- (void)bind;

- (id)initCellModelWithMessage:(LGBotMenuMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator;


@end

NS_ASSUME_NONNULL_END
