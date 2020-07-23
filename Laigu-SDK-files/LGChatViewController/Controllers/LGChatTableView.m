//
//  LGChatTableView.m
//  LaiGuSDK
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import "LGChatTableView.h"
#import "LGChatViewConfig.h"
#import "LGStringSizeUtil.h"
#import "LGBundleUtil.h"
#import "LGToolUtil.h"

//static CGFloat const kLGChatScrollBottomDistanceThreshold = 128.0;

@interface LGChatTableView()

@end

@implementation LGChatTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    
    if (LGToolUtil.kXlpObtainDeviceVersionIsIphoneX) {
        CGFloat newHeight = frame.size.height - 34;
        frame.size.height = newHeight;
    }
    
    if (LGToolUtil.kXlpObtainStatusBarHeight == 0 && frame.size.width > frame.size.height) {
        frame.size.width = frame.size.width - 64;
    }
    
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITapGestureRecognizer *tapViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChatTableView:)];
        tapViewGesture.cancelsTouchesInView = false;
        self.userInteractionEnabled = true;
        [self addGestureRecognizer:tapViewGesture];
        
        
    }
    return self;
}

- (void)updateTableViewAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self numberOfRowsInSection:0]) {
        [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}


/** 点击tableView的事件 */
- (void)tapChatTableView:(id)sender {
    if (self.chatTableViewDelegate) {
        if ([self.chatTableViewDelegate respondsToSelector:@selector(didTapChatTableView:)]) {
            [self.chatTableViewDelegate didTapChatTableView:self];
        }
    }
}

- (void)scrollToCellIndex:(NSInteger)index {
    if ([self numberOfRowsInSection:0] > 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (BOOL)isTableViewScrolledToBottom {
//    if(self.contentOffset.y + self.frame.size.height + kLGChatScrollBottomDistanceThreshold > self.contentSize.height){
//        return true;
//    } else {
//        return false;
//    }
    CGFloat distanceFromBottom = self.contentSize.height - self.contentOffset.y;
    
    if (distanceFromBottom <= self.frame.size.height + 200){
        return YES;
    }
    return NO;

}

@end
