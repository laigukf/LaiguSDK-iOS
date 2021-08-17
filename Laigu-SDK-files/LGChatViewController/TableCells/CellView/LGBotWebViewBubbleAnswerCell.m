//
//  LGBotWebViewBubbleAnswerCell.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/9/5.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGBotWebViewBubbleAnswerCell.h"
#import "LGBotWebViewBubbleAnswerCellModel.h"
#import "UIView+LGLayout.h"
#import "LGChatViewConfig.h"
#import "LGImageUtil.h"
#import "LGBundleUtil.h"


#define TAG_MENUS 10
#define TAG_EVALUATE 11
#define HEIHGT_VIEW_EVALUATE 40
#define FONT_SIZE_CONTENT 16
#define FONT_SIZE_MENU_TITLE 13
#define FONT_SIZE_MENU 15
#define FONT_SIZE_MENU_FOOTNOTE 12
#define FONT_SIZE_EVALUATE_BUTTON 14
#define SPACE_INTERNAL_VERTICAL 15

@interface LGBotWebViewBubbleAnswerCell()

@property (nonatomic, strong) UIImageView *itemsView; //底部气泡
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) LGEmbededWebView *contentWebView;
@property (nonatomic, strong) UIView *evaluateView; //包含已解决 未解决2个按钮
@property (nonatomic, strong) UIView *evaluatedView; //包含 已反馈 按钮
@property (nonatomic, assign) BOOL manuallySetToEvaluated;
@property (nonatomic, strong) LGBotWebViewBubbleAnswerCellModel *viewModel;

@end

@implementation LGBotWebViewBubbleAnswerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.itemsView];
        [self.itemsView addSubview:self.contentWebView];
        [self layoutUI];
        [self updateUI:0];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    self.manuallySetToEvaluated = NO;
    self.viewModel = model;
    
    __weak typeof(self) wself = self;
    
    [self.viewModel setCellHeight:^CGFloat{
        __strong typeof (wself) sself = wself;
        if (sself.viewModel.cachedWebViewHeight > 0) {
            return sself.viewModel.cachedWebViewHeight + kLGCellAvatarToVerticalEdgeSpacing + kLGCellAvatarToVerticalEdgeSpacing + HEIHGT_VIEW_EVALUATE + SPACE_INTERNAL_VERTICAL;
        }
        return sself.viewHeight;
    }];
    
    [self.viewModel setAvatarLoaded:^(UIImage *avatar) {
       __strong typeof (wself) sself = wself;
        sself.avatarImageView.image = avatar;
    }];
    
    [self.contentWebView loadHTML:self.viewModel.content WithCompletion:^(CGFloat height) {
        __strong typeof (wself) sself = wself;
        if (height != self.viewModel.cachedWebViewHeight) {
            [sself.viewModel setCachedWebViewHeight:height];
            [sself updateUI:height];
            [sself.chatCellDelegate reloadCellAsContentUpdated:sself messageId:[sself.viewModel getCellMessageId]];
        }
    }];
    
    [self.contentWebView setTappedLink:^(NSURL *url) {
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    if (self.viewModel.cachedWebViewHeight > 0) {
        [self updateUI:self.viewModel.cachedWebViewHeight];
    }
    
    [self.viewModel bind];
}

- (void)layoutUI {
    
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarToHorizontalEdgeSpacing)];
    [self.itemsView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kLGCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    self.itemsView.viewWidth = self.contentView.viewWidth - kLGCellBubbleMaxWidthToEdgeSpacing - self.avatarImageView.viewRightEdge;
    self.contentWebView.viewWidth = self.itemsView.viewWidth - 8;
    self.contentWebView.viewX = 8;
}

- (void)updateUI:(CGFloat)webContentHeight {
    
    self.contentWebView.viewHeight = webContentHeight;
    //recreate evaluate view
    UIView *evaluateView = [self evaluateRelatedView];
    [[self.itemsView viewWithTag:evaluateView.tag] removeFromSuperview];
    [self.itemsView addSubview:evaluateView];
    
    [evaluateView align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(8, self.contentWebView.viewBottomEdge + SPACE_INTERNAL_VERTICAL)];
    
    CGFloat bubbleHeight = MAX(self.avatarImageView.viewHeight, evaluateView.viewBottomEdge);
    self.itemsView.viewHeight = bubbleHeight;
    self.contentView.viewHeight = self.itemsView.viewBottomEdge + kLGCellAvatarToVerticalEdgeSpacing;
    self.viewHeight = self.contentView.viewHeight;
}

#pragma mark - actions

- (void)didTapPositive {
    
    [self updateEvaluateViewAnimatedComplete:^{
        if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
            [self.chatCellDelegate evaluateBotAnswer:true messageId:self.viewModel.messageId];
        }
    }];
}

- (void)didTapNegative {
    [self updateEvaluateViewAnimatedComplete:^{
        if ([self.chatCellDelegate respondsToSelector:@selector(evaluateBotAnswer:messageId:)]) {
            [self.chatCellDelegate evaluateBotAnswer:false messageId:self.viewModel.messageId];
        }
    }];
}

- (void)updateEvaluateViewAnimatedComplete:(void(^)(void))action {
    self.manuallySetToEvaluated = YES;
    
    UIView *oldView = [self.itemsView viewWithTag:TAG_EVALUATE];
    
    UIView *newView = [self evaluateRelatedView];
    newView.alpha = 0.0;
    newView.frame = oldView.frame;
    [self.itemsView addSubview:newView];
    
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            oldView.alpha = 0.0;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            newView.alpha = 1.0;
        }];
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
        if (action) {
            action();
        }
    }];
}

- (UIView *)evaluateRelatedView {
    UIView *view;
    if (self.viewModel.isEvaluated || self.manuallySetToEvaluated) {
        if (self.evaluateView.superview) {
            [self.evaluateView removeFromSuperview];
        }
        view = self.evaluatedView;
    } else {
        if (self.evaluatedView.superview) {
            [self.evaluatedView removeFromSuperview];
        }
        view = self.evaluateView;
    }
    
    view.tag = TAG_EVALUATE;
    return view;
}

#pragma - lazy

- (LGEmbededWebView *)contentWebView {
    if (!_contentWebView) {
        _contentWebView = [LGEmbededWebView new];
        _contentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _contentWebView;
}

- (UIImageView *)itemsView {
    if (!_itemsView) {
        _itemsView = [UIImageView new];
        _itemsView.userInteractionEnabled = true;
        UIImage *bubbleImage = [LGChatViewConfig sharedConfig].incomingBubbleImage;
        if ([LGChatViewConfig sharedConfig].incomingBubbleColor) {
            bubbleImage = [LGImageUtil convertImageColorWithImage:bubbleImage toColor:[LGChatViewConfig sharedConfig].incomingBubbleColor];
        }
        bubbleImage = [bubbleImage resizableImageWithCapInsets:[LGChatViewConfig sharedConfig].bubbleImageStretchInsets];
        _itemsView.image = bubbleImage;
        _itemsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _itemsView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.viewSize = CGSizeMake(kLGCellAvatarDiameter, kLGCellAvatarDiameter);
        _avatarImageView.image = [LGChatViewConfig sharedConfig].incomingDefaultAvatarImage;
        if ([LGChatViewConfig sharedConfig].enableRoundAvatar) {
            _avatarImageView.layer.masksToBounds = YES;
            _avatarImageView.layer.cornerRadius = _avatarImageView.viewSize.width/2;
        }
    }
    return _avatarImageView;
}

- (UIView *)evaluateView {
    //    if (!_evaluateView) {
    _evaluateView = [UIView new];
    _evaluateView.viewWidth = self.itemsView.viewWidth - 8;
    _evaluateView.viewHeight = HEIHGT_VIEW_EVALUATE;
    _evaluateView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth;
    
    UIView *lineH = [UIView new];
    lineH.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    lineH.viewHeight = 0.5;
    lineH.viewWidth = _evaluateView.viewWidth;
    lineH.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIButton *usefulButton = [UIButton new];
    usefulButton.viewWidth = _evaluateView.viewWidth / 2 - 0.5;
    usefulButton.viewHeight = _evaluateView.viewHeight - 0.5;
    usefulButton.viewY = 0.5;
    [usefulButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_EVALUATE_BUTTON]];
    usefulButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    [usefulButton setTitle:[LGBundleUtil localizedStringForKey:@"lg_solved"] forState:(UIControlStateNormal)];
    [usefulButton setTitleColor:[LGChatViewConfig sharedConfig].chatViewStyle.btnTextColor forState:(UIControlStateNormal)];
    [usefulButton addTarget:self action:@selector(didTapPositive) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIView *lineV = [UIView new];
    lineV.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    lineV.viewHeight = HEIHGT_VIEW_EVALUATE;
    lineV.viewWidth = 0.5;
    [lineV align:(ViewAlignmentTopLeft) relativeToPoint:usefulButton.rightTopCorner];
    lineV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    UIButton *uselessButton = [UIButton new];
    [uselessButton setTitleColor:[LGChatViewConfig sharedConfig].chatViewStyle.btnTextColor forState:(UIControlStateNormal)];
    [uselessButton setTitle:[LGBundleUtil localizedStringForKey:@"lg_unsolved"] forState:(UIControlStateNormal)];
    [uselessButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_EVALUATE_BUTTON]];
    [uselessButton addTarget:self action:@selector(didTapNegative) forControlEvents:(UIControlEventTouchUpInside)];
    uselessButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    uselessButton.viewWidth = _evaluateView.viewWidth / 2;
    uselessButton.viewHeight = _evaluateView.viewHeight - 0.5;
    uselessButton.viewY = 0.5;
    [uselessButton align:(ViewAlignmentTopLeft) relativeToPoint:CGPointMake(usefulButton.viewRightEdge + 0.5, usefulButton.viewY)];
    
    [_evaluateView addSubview:lineH];
    [_evaluateView addSubview:lineV];
    [_evaluateView addSubview:usefulButton];
    [_evaluateView addSubview:uselessButton];
    //    }
    return _evaluateView;
}

- (UIView *)evaluatedView {
    //    if (!_evaluatedView) {
    _evaluatedView = [UIView new];
    _evaluatedView.viewWidth = self.itemsView.viewWidth - 8;
    _evaluatedView.viewHeight = HEIHGT_VIEW_EVALUATE;
    _evaluatedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIView *lineH = [UIView new];
    lineH.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    lineH.viewHeight = 0.5;
    lineH.viewWidth = _evaluatedView.viewWidth;
    lineH.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_evaluatedView addSubview:lineH];
    
    UIButton *button = [UIButton new];
    button.viewWidth = _evaluatedView.viewWidth;
    button.viewHeight = _evaluatedView.viewHeight - 0.5;
    button.viewY = 0.5;
    [button setTitleColor:[UIColor lightGrayColor] forState:(UIControlStateNormal)];
    [button.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_EVALUATE_BUTTON]];
    [button setTitle:[LGBundleUtil localizedStringForKey:@"lg_commited"] forState:(UIControlStateNormal)];
    [button setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
    [_evaluatedView addSubview:button];
    //    }
    return _evaluatedView;
}
@end
