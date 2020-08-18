//
//  LGRecorderView.h
//  Laigu
//
//  Created by zhangshunxing on 16/5/10.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGRecorderViewDelegate <NSObject>

//- (NSString *)voiceFilePath;

- (void)recordEnd;

- (void)recordStarted;

- (void)recordCanceld;

@end

@interface LGRecorderView : UIView

@property (nonatomic, weak) id<LGRecorderViewDelegate> delegate;

@property (nonatomic, strong, readonly) UILabel *tipLabel;

- (void)changeVolumeLayerDiameter:(CGFloat)dia;

@end
