//
//  LGRecorderView.h
//  Laigu
//
//  Created by Injoy on 16/5/10.
//  Copyright © 2016年 Injoy. All rights reserved.
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
