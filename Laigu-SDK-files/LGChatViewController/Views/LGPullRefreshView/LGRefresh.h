//
//  LGRefresh.h
//  Laigu-SDK-Demo
//
//  Created by ian luo on 2017/2/20.
//  Copyright © 2017年 Laigu. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - UITableView(LGRefresh)
/*
@class LGRefresh;
@interface UITableView(LGRefresh)

@property (nonatomic) LGRefresh *refreshView;

- (void)setupPullRefreshWithAction:(void(^)(void))action;
- (void)startAnimation;
- (void)stopAnimationCompletion:(void(^)(void))action;
- (void)setLoadEnded;

@end
*/
#import "LGChatTableView.h"
@class LGRefresh;
@interface LGChatTableView (LGRefresh)

@property (nonatomic) LGRefresh *refreshView;
- (void)setupPullRefreshWithAction:(void(^)(void))action;
- (void)startAnimation;
- (void)stopAnimationCompletion:(void(^)(void))action;
- (void)setLoadEnded;

@end


/****xlp分割*****/
typedef NS_ENUM(NSUInteger, LGRefreshStatus) {
    LGRefreshStatusNormal,
    LGRefreshStatusDraging,
    LGRefreshStatusTriggered,
    LGRefreshStatusLoading,
    LGRefreshStatusEnd,
};

#pragma mark - LGRefresh

@interface LGRefresh : UIView

@property (nonatomic, assign, readonly) LGRefreshStatus status;

- (BOOL)updateCustomViewForStatus:(LGRefreshStatus)status;
- (void)updateTextForStatus:(LGRefreshStatus)status;
- (void)setLoadEnd;
- (void)updateStatusWithTopOffset:(CGFloat)topOffset;
- (void)setText:(NSString *)text forStatus:(LGRefreshStatus)status;
- (void)setView:(UIView *)view forStatus:(LGRefreshStatus)status;
- (void)setIsLoading:(BOOL)isLoading;

@end
