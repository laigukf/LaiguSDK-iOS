//
//  LGMessageFormCategoryViewController.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 2016/10/10.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGMessageFormCategoryViewController : UITableViewController

@property (nonatomic, copy) void(^categorySelected)(NSString *categoryId);

- (void)showIfNeededOn:(UIViewController *)controller;

@end
