//
//  LGImageViewerViewController.h
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/5/9.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGImageViewerViewController : UIViewController

@property (nonatomic, strong) NSArray *imagePaths;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, copy) void(^selection)(NSUInteger index);

@property (nonatomic, assign) BOOL shouldHideSaveBtn;

- (void)showOn:(UIViewController *)controller fromRectArray:(NSArray *)rectArray;

- (void)dismiss;
@end

@interface LGImageCollectionCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, copy) void(^tapOnImage)(void);


@end
