//
//  LGAdviseFormSubmitViewController.h
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LaiGuSDK/LaiguSDK.h>
#import "LGChatViewConfig.h"

@interface LGPreChatSubmitViewController : UITableViewController

@property (nonatomic, copy) void(^completeBlock)(NSDictionary *userInfo);
@property (nonatomic, copy) void(^cancelBlock)(void);

@property (nonatomic, strong) LGPreChatData *formData;
@property (nonatomic, strong) LGPreChatMenuItem *selectedMenuItem;

@end
