//
//  LGSplitLineCellModel.h
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/21.
//  Copyright © 2020 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGCellModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LGSplitLineCellModel : NSObject<LGCellModelProtocol>

@property (nonatomic, readonly, assign) CGRect labelFrame;
@property (nonatomic, readonly, assign) CGRect leftLineFrame;
@property (nonatomic, readonly, assign) CGRect rightLineFrame;

- (LGSplitLineCellModel *)initCellModelWithCellWidth:(CGFloat)cellWidth withConversionDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
