//
//  LGMessageFormImageCell.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/5/24.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGMessageFormImageCellDelegate <NSObject>

- (void)tapDeleteIv:(NSUInteger)index;

- (void)tapPictureIv:(NSUInteger)index;

@end

@interface LGMessageFormImageCell : UICollectionViewCell

@property(nonatomic, weak) id<LGMessageFormImageCellDelegate> delegate;
@property(nonatomic, weak) NSIndexPath *indexPath;

@property (strong, nonatomic) UIImageView *pictureIv;
@property (strong, nonatomic) UIImageView *deleteIv;

@end
