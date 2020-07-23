//
//  LGMessageFormImageView.h
//  LaiGuSDK
//
//  Created by bingoogolapple on 16/5/4.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGMessageFormImageViewDelegate <NSObject>

- (void)choosePictureWithSourceType:(UIImagePickerControllerSourceType *)sourceType;

@end

@interface LGMessageFormImageView : UICollectionView

@property(nonatomic, weak) id<LGMessageFormImageViewDelegate> choosePictureDelegate;

- (instancetype)initWithScreenWidth:(CGFloat)screenWidth;

- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y;

- (void)addImage:(UIImage *)image;

- (NSArray *)getImages;
@end
