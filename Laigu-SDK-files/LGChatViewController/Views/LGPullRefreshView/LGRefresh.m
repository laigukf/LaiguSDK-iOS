//
//  LGRefresh.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 2017/2/20.
//  Copyright © 2017年 Laigu. All rights reserved.
//

#import "LGRefresh.h"
#import "LGToolUtil.h"
#import <objc/runtime.h>

#pragma mark - UITableView(LGRefresh)
/*
@interface UITableView(LGRefresh_private)

@end

static id keyUITableViewView, keyUITableViewLGRefreshAction, keyUITableViewLGRefreshObserverCount;
@implementation UITableView (LGRefresh)

- (NSUInteger)keyPathObserverCount {
    return [(NSNumber *)objc_getAssociatedObject(self, &keyUITableViewLGRefreshObserverCount) unsignedIntegerValue];
}

- (void)increaseKeyPathObserverCount {
    NSUInteger currentCount = [self keyPathObserverCount];
    objc_setAssociatedObject(self, &keyUITableViewLGRefreshObserverCount, @(currentCount + 1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// ------

- (void(^)(void))action {
    return (void(^)(void))objc_getAssociatedObject(self, &keyUITableViewLGRefreshAction);
}

- (void)setAction:(void(^)(void))v {
    objc_setAssociatedObject(self, &keyUITableViewLGRefreshAction, v, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

// --------

- (LGRefresh *)refreshView {
    return (LGRefresh *)objc_getAssociatedObject(self, &keyUITableViewView);
}

- (void)setRefreshView:(LGRefresh *)v {
    objc_setAssociatedObject(self, &keyUITableViewView, v, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// -----

- (void)setupPullRefreshWithAction:(void(^)(void))action {
    self.action = action;
    
    self.refreshView = [[LGRefresh alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    [self.refreshView setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
    self.refreshView.frame = CGRectMake(0, -self.refreshView.bounds.size.height, self.refreshView.bounds.size.width, self.refreshView.bounds.size.height);
    [self addSubview:self.refreshView];
    
    [self addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew) context:nil];
    [self increaseKeyPathObserverCount];
}

- (void)dealloc {
    if ([self keyPathObserverCount] > 0) {
        [self removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)startAnimation {
    if (self.refreshView.status != LGRefreshStatusEnd) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        [self.refreshView setView:indicator forStatus:LGRefreshStatusLoading];
        UIEdgeInsets currentInsects = self.contentInset;
        currentInsects.top += self.refreshView.bounds.size.height;
        
        [self.refreshView setIsLoading:YES];
        
        [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setContentInset: currentInsects];
            self.contentOffset = CGPointMake(0, -self.contentInset.top);
        } completion:^(BOOL finished) {
            if (self.action) {
                self.action();
            }
        }];
    }
}

- (void)stopAnimationCompletion:(void(^)(void))action {
    UIEdgeInsets currentInsects = self.contentInset;
    currentInsects.top -= self.refreshView.bounds.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setContentInset: currentInsects];
        self.contentOffset = CGPointMake(0, -self.contentInset.top);
    } completion:^(BOOL finished) {
        [self.refreshView setIsLoading:NO];
        if (action) {
            action();
        }
    }];
}

- (void)setLoadEnded {
    [self.refreshView setLoadEnd];
    UIEdgeInsets currentInsects = self.contentInset;
    currentInsects.top += self.refreshView.bounds.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        [self setContentInset: currentInsects];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        [self.refreshView updateStatusWithTopOffset:contentOffset.y + self.contentInset.top];
    }
}

@end
*/
/**********/

static id keyUITableViewView, keyUITableViewLGRefreshAction, keyUITableViewLGRefreshObserverCount;

@implementation LGChatTableView (LGRefresh)

- (NSUInteger)keyPathObserverCount {
    return [(NSNumber *)objc_getAssociatedObject(self, &keyUITableViewLGRefreshObserverCount) unsignedIntegerValue];
}

- (void)increaseKeyPathObserverCount {
    NSUInteger currentCount = [self keyPathObserverCount];
    objc_setAssociatedObject(self, &keyUITableViewLGRefreshObserverCount, @(currentCount + 1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// ------

- (void(^)(void))action {
    return (void(^)(void))objc_getAssociatedObject(self, &keyUITableViewLGRefreshAction);
}

- (void)setAction:(void(^)(void))v {
    objc_setAssociatedObject(self, &keyUITableViewLGRefreshAction, v, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

// --------

- (LGRefresh *)refreshView {
    return (LGRefresh *)objc_getAssociatedObject(self, &keyUITableViewView);
}

- (void)setRefreshView:(LGRefresh *)v {
    objc_setAssociatedObject(self, &keyUITableViewView, v, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// -----

- (void)setupPullRefreshWithAction:(void(^)(void))action {
    self.action = action;
    
    self.refreshView = [[LGRefresh alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    [self.refreshView setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
    self.refreshView.frame = CGRectMake(0, -self.refreshView.bounds.size.height, self.refreshView.bounds.size.width, self.refreshView.bounds.size.height);
    [self addSubview:self.refreshView];
    
    [self addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew) context:nil];
    [self increaseKeyPathObserverCount];
}

- (void)dealloc {
    if ([self keyPathObserverCount] > 0) {
        [self removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)startAnimation {
    if (self.refreshView.status != LGRefreshStatusEnd) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        [self.refreshView setView:indicator forStatus:LGRefreshStatusLoading];
        UIEdgeInsets currentInsects = self.contentInset;
        currentInsects.top += self.refreshView.bounds.size.height;
        
        [self.refreshView setIsLoading:YES];
        
        [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setContentInset: currentInsects];
            self.contentOffset = CGPointMake(0, -self.contentInset.top);
        } completion:^(BOOL finished) {
            if (self.action) {
                self.action();
            }
        }];
    }
}

- (void)stopAnimationCompletion:(void(^)(void))action {
    UIEdgeInsets currentInsects = self.contentInset;
    currentInsects.top -= self.refreshView.bounds.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setContentInset: currentInsects];
        self.contentOffset = CGPointMake(0, -self.contentInset.top);
    } completion:^(BOOL finished) {
        [self.refreshView setIsLoading:NO];
        if (action) {
            action();
        }
    }];
}

- (void)setLoadEnded {
    [self.refreshView setLoadEnd];
    UIEdgeInsets currentInsects = self.contentInset;
    currentInsects.top += self.refreshView.bounds.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        [self setContentInset: currentInsects];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        [self.refreshView updateStatusWithTopOffset:contentOffset.y + self.contentInset.top];
    }
}


@end

/**********/
#pragma mark - LGRefresh

@interface LGRefresh()

@property (nonatomic, assign) LGRefreshStatus status;
@property (nonatomic, strong) NSMutableDictionary *textMap;
@property (nonatomic, strong) NSMutableDictionary *viewMap;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *customViewContainer;

@end

@implementation LGRefresh

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.textMap = [@{
                      @(LGRefreshStatusNormal) : @"下拉加载历史消息",
                      @(LGRefreshStatusDraging) : @"Pull down",
                      @(LGRefreshStatusTriggered) : @"Release to load",
                      @(LGRefreshStatusLoading) : @"Loading...",
                      @(LGRefreshStatusEnd) : @"No more data",
                      } mutableCopy];
    
    self.viewMap = [NSMutableDictionary new];
    
    //
    [self addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
    //
    [self setupUI];
}

- (void)setupUI {
    self.textLabel = [UILabel new];
    [self.textLabel setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
    self.textLabel.frame = self.bounds;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.customViewContainer = [UIView new];
    [self.customViewContainer setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
    self.customViewContainer.frame = self.bounds;
    self.textLabel.textColor = [UIColor grayColor];
    self.textLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleFootnote];
    [self addSubview: self.customViewContainer];
    [self addSubview:self.textLabel];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"status"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        NSNumber *new = (NSNumber *)change[NSKeyValueChangeNewKey];
        NSNumber *old = (NSNumber *)change[NSKeyValueChangeOldKey];
        if (new.unsignedIntegerValue != old.unsignedIntegerValue) {
            [self updateForStatus: (LGRefreshStatus)[new unsignedIntegerValue]];
        }
    }
}

- (void)updateStatusWithTopOffset:(CGFloat)topOffset {
    if (topOffset > 0) { return; }
    
    if (self.status == LGRefreshStatusLoading || self.status == LGRefreshStatusEnd) { return; }
    
    
    CGFloat mm = LGToolUtil.kXlpObtainNaviHeight ;
    
    if (topOffset == 0|| topOffset == - mm) {
        self.status = LGRefreshStatusNormal;
    } else if (topOffset < -self.bounds.size.height) {
        self.status = LGRefreshStatusTriggered;
    } else if (topOffset < 0) {
        self.status = LGRefreshStatusDraging;
    }
}

- (void)setIsLoading:(BOOL)isLoading {
    if (isLoading) {
        [self updateForStatus: LGRefreshStatusLoading];
    } else {
        [self updateForStatus: LGRefreshStatusNormal];
    }
}

- (void)setLoadEnd {
    [self updateForStatus:LGRefreshStatusEnd];
}

- (void)updateForStatus:(LGRefreshStatus)status {
    self.status = status;
    if (![self updateCustomViewForStatus: status]) {
        [self updateTextForStatus:status];
    }
}

- (void)updateTextForStatus:(LGRefreshStatus)status {
    self.textLabel.text = self.textMap[@(status)];
}

- (BOOL)updateCustomViewForStatus:(LGRefreshStatus)status {
    [self.customViewContainer.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    UIView *customView = self.viewMap[@(status)];
    if (customView != nil) { // use customized view
        [self.customViewContainer addSubview:customView];
        [customView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
        
        self.textLabel.hidden = YES;
        self.customViewContainer.hidden = NO;
        return YES;
    } else {
        self.textLabel.hidden = NO;
        self.customViewContainer.hidden = YES;
        return NO;
    }
}

- (void)setText:(NSString *)text forStatus:(LGRefreshStatus)status {
    if (text.length > 0) {
        self.textMap[@(status)] = text;
    }
}

- (void)setView:(UIView *)view forStatus:(LGRefreshStatus)status {
    assert([view isKindOfClass:UIView.class]);
    self.viewMap[@(status)] = view;
}

@end
