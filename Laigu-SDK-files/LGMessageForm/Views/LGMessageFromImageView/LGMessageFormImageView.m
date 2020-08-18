//
//  LGMessageFormImageView.m
//  LaiGuSDK
//
//  Created by zhangshunxing on 16/5/4.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import "LGMessageFormImageView.h"
#import "LGAssetUtil.h"
#import "LGBundleUtil.h"
#import "LGMessageFormConfig.h"
#import "LGImageViewerViewController.h"
#import "LGMessageFormImageCell.h"

static CGFloat const kLGMessageFormImageViewSpacing   = 16.0;
static CGFloat const kLGMessageFormImageViewMaxPictureItemLength = 116;
static CGFloat const kLGMessageFormImageViewMaxItemCount = 3;
static CGFloat const kLGMessageFormImageViewItemSpacing = 7;
static CGFloat const kLGMessageFormImageViewHeaderHeight = 20;

static NSString * const kLGMessageFormImageViewCellID = @"LGMessageFormImageCell";
static NSString * const kLGMessageFormImageViewCellHeaderID = @"LGMessageFormImageCellHeader";

@interface LGMessageFormImageView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LGMessageFormImageCellDelegate>

@end

@implementation LGMessageFormImageView {
    NSMutableArray *images;
}

- (instancetype)initWithScreenWidth:(CGFloat)screenWidth {
    CGFloat pictureItemLength = [LGMessageFormImageView calculatePictureItemLengthWithScreenWidth:screenWidth];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(pictureItemLength, pictureItemLength);
    layout.minimumLineSpacing = kLGMessageFormImageViewItemSpacing;
    layout.minimumInteritemSpacing = kLGMessageFormImageViewItemSpacing;
    
    CGFloat width = pictureItemLength * kLGMessageFormImageViewMaxItemCount + kLGMessageFormImageViewItemSpacing * (kLGMessageFormImageViewMaxItemCount - 1);
    self = [super initWithFrame:CGRectMake(kLGMessageFormImageViewSpacing, kLGMessageFormImageViewSpacing, width, pictureItemLength + kLGMessageFormImageViewHeaderHeight) collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[LGMessageFormImageCell class] forCellWithReuseIdentifier:kLGMessageFormImageViewCellID];
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kLGMessageFormImageViewCellHeaderID];

        images = [NSMutableArray new];
        [images addObject:[LGMessageFormConfig sharedConfig].messageFormViewStyle.addImage ?: [UIImage imageNamed:[LGAssetUtil resourceWithName:@"LGMessageFormAddIcon"]]];
    }
    return self;
}

+ (CGFloat)calculatePictureItemLengthWithScreenWidth:(CGFloat)screenWidth {
    CGFloat pictureItemLength = (screenWidth - 2 * kLGMessageFormImageViewSpacing - kLGMessageFormImageViewItemSpacing * (kLGMessageFormImageViewMaxItemCount - 1)) / kLGMessageFormImageViewMaxItemCount;
    pictureItemLength = pictureItemLength > kLGMessageFormImageViewMaxPictureItemLength ? kLGMessageFormImageViewMaxPictureItemLength : pictureItemLength;
    return pictureItemLength;
}

#pragma UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LGMessageFormImageCell *cell = (LGMessageFormImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLGMessageFormImageViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    cell.pictureIv.image = [images objectAtIndex:indexPath.row];
    if (indexPath.row == images.count - 1 && [images lastObject] == [LGMessageFormConfig sharedConfig].messageFormViewStyle.addImage) {
        cell.deleteIv.hidden = YES;
    } else {
        cell.deleteIv.hidden = NO;
    }
    // 图片数达到上限后，隐藏「添加」图片
    if (images.count == kLGMessageFormImageViewMaxItemCount + 1 && indexPath.row == images.count - 1) {
        cell.hidden = YES;
    } else {
        cell.hidden = NO;
    }
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, kLGMessageFormImageViewHeaderHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kLGMessageFormImageViewCellHeaderID forIndexPath:indexPath];
    UILabel *addPictureLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    addPictureLabel.text = [LGBundleUtil localizedStringForKey:@"add_picture"];
    addPictureLabel.textColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.addPictureTextColor;
    addPictureLabel.font = [UIFont systemFontOfSize:14.0];
    [headerView addSubview:addPictureLabel];
    return headerView;
}

#pragma LGMessageFormImageCellDelegate
- (void)tapDeleteIv:(NSUInteger)index {
    // 若少于上限，则显示「添加」图片
    if ([images lastObject] != [LGMessageFormConfig sharedConfig].messageFormViewStyle.addImage) {
        [images removeObjectAtIndex:index];
        [images addObject:[LGMessageFormConfig sharedConfig].messageFormViewStyle.addImage];
        [self reloadData];
    } else {
        [images removeObjectAtIndex:index];
        [self performBatchUpdates:^{
            [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        } completion:^(BOOL finished) {
            [self reloadData];
        }];
    }
}

- (void)tapPictureIv:(NSUInteger)index {
    if (index == images.count - 1) {
        [self showChoosePictureActionSheet];
    } else {
        [self showImageViewerWithIndex:index];
    }
}

- (void)showImageViewerWithIndex:(NSUInteger)index {
    LGImageViewerViewController *viewerVC = [LGImageViewerViewController new];
    viewerVC.images = [images subarrayWithRange:NSMakeRange(0, images.count - 1)];
    viewerVC.currentIndex = index;
    viewerVC.shouldHideSaveBtn = YES;
    
    __weak LGImageViewerViewController *wViewerVC = viewerVC;
    [viewerVC setSelection:^(NSUInteger index) {
        __strong LGImageViewerViewController *sViewerVC = wViewerVC;
        [sViewerVC dismiss];
    }];
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [viewerVC showOn:[UIApplication sharedApplication].keyWindow.rootViewController fromRectArray:[self getFromRectArray]];
}

- (NSArray *)getFromRectArray {
    NSMutableArray *fromRectArray = [NSMutableArray new];
    for (int i = 0; i < images.count - 1; i++) {
        LGMessageFormImageCell *cell = (LGMessageFormImageCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [fromRectArray addObject:[NSValue valueWithCGRect:[cell.pictureIv.superview convertRect:cell.pictureIv.frame toView:[UIApplication sharedApplication].keyWindow]]];
    }
    return fromRectArray;
}


- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y {
    CGFloat pictureItemLength = [LGMessageFormImageView calculatePictureItemLengthWithScreenWidth:screenWidth];
    CGFloat width = pictureItemLength * kLGMessageFormImageViewMaxItemCount + kLGMessageFormImageViewItemSpacing * (kLGMessageFormImageViewMaxItemCount - 1);
    self.frame = CGRectMake(kLGMessageFormImageViewSpacing, y + kLGMessageFormImageViewSpacing, width, pictureItemLength + kLGMessageFormImageViewHeaderHeight);
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.itemSize = CGSizeMake(pictureItemLength, pictureItemLength);
}

- (void)addImage:(UIImage *)image {
    // 达到上限时，清楚「添加」图片
    if (images.count == kLGMessageFormImageViewMaxItemCount) {
        [images replaceObjectAtIndex:kLGMessageFormImageViewMaxItemCount - 1 withObject:image];
    } else {
        [images insertObject:image atIndex:images.count - 1];
    }
    [self reloadData];
}

- (NSArray *)getImages {
    // 如果最后一张图片是「加号图片」，则返回「加号图片」以外的图片数组
    if ([images lastObject] == [LGMessageFormConfig sharedConfig].messageFormViewStyle.addImage) {
        return [images subarrayWithRange:NSMakeRange(0, images.count - 1)];
    } else {
        return images;
    }
}

- (void)showChoosePictureActionSheet {
    // 先关闭键盘，否则会被键盘遮住
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:[LGBundleUtil localizedStringForKey:@"cancel"] destructiveButtonTitle:nil otherButtonTitles:[LGBundleUtil localizedStringForKey:@"select_gallery"], [LGBundleUtil localizedStringForKey:@"select_camera"], nil];
    [sheet showInView:self.superview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            if ([self.choosePictureDelegate respondsToSelector:@selector(choosePictureWithSourceType:)]) {
                [self.choosePictureDelegate choosePictureWithSourceType:(NSInteger*)UIImagePickerControllerSourceTypePhotoLibrary];
            }
            break;
        }
        case 1: {
            if ([self.choosePictureDelegate respondsToSelector:@selector(choosePictureWithSourceType:)]) {
                [self.choosePictureDelegate choosePictureWithSourceType:(NSInteger*)UIImagePickerControllerSourceTypeCamera];
            }
            break;
        }
    }
    actionSheet = nil;
}

@end
