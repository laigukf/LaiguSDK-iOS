//
//  LGPreAdviseFormListViewController.h
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LGChatViewConfig;
@interface LGPreChatFormListViewController : UITableViewController

+ (LGPreChatFormListViewController *)usePreChatFormIfNeededOnViewController:(UIViewController *)controller compeletion:(void(^)(NSDictionary *userInfo))block cancle:(void(^)(void))cancelBlock;


@end
