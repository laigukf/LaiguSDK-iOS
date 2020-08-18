//
//  LGWebViewBubbleCell.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/9/5.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGWebViewBubbleCell.h"
#import "LGChatViewConfig.h"
#import "UIView+LGLayout.h"
#import "LGCellModelProtocol.h"
#import "LGImageUtil.h"
#import "LGWebViewBubbleCellModel.h"

@interface LGWebViewBubbleCell()

@property (nonatomic, strong) LGWebViewBubbleCellModel *viewModel;
@property (nonatomic, strong) UIImageView *itemsView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) LGEmbededWebView *contentWebView;

@end

@implementation LGWebViewBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.avatarImageView];
        [self addSubview:self.itemsView];
        [self.itemsView addSubview:self.contentWebView];
        [self layoutUI];
        [self updateUI:0];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    self.viewModel = model;
    
    __weak typeof(self) wself = self;
    
    [self.viewModel setCellHeight:^CGFloat{
        __strong typeof (wself) sself = wself;
        
        if (sself.viewModel.cachedWetViewHeight) {
            return sself.viewModel.cachedWetViewHeight + kLGCellAvatarToVerticalEdgeSpacing + kLGCellAvatarToVerticalEdgeSpacing;
        }
        return sself.viewHeight;
    }];
    
    [self.viewModel setAvatarLoaded:^(UIImage *avatar) {
        __strong typeof (wself) sself = wself;
        sself.avatarImageView.image = avatar;
    }];
    
    [self.contentWebView loadHTML:self.viewModel.content WithCompletion:^(CGFloat height) {
        __strong typeof (wself) sself = wself;
        if (sself.viewModel.cachedWetViewHeight != height) {
            [sself updateUI:height];
            sself.viewModel.cachedWetViewHeight = height;
            [sself.chatCellDelegate reloadCellAsContentUpdated:sself messageId:[sself.viewModel getCellMessageId]];
        }
    }];
    
    [self.contentWebView setTappedLink:^(NSURL *url) {
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    if (self.viewModel.cachedWetViewHeight > 0) {
        [self updateUI:self.viewModel.cachedWetViewHeight];
    }
    
    [self.viewModel bind];
}

- (void)layoutUI {
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarToVerticalEdgeSpacing)];
    [self.itemsView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kLGCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    self.itemsView.viewWidth = self.contentView.viewWidth - kLGCellBubbleMaxWidthToEdgeSpacing - self.avatarImageView.viewRightEdge;
    
    self.contentWebView.viewWidth = self.itemsView.viewWidth - 8;
    self.contentWebView.viewX = 8;
}

- (void)updateUI:(CGFloat)webContentHeight {
    CGFloat bubbleHeight = MAX(self.avatarImageView.viewHeight, webContentHeight);
    
    self.contentWebView.viewHeight = webContentHeight;
    self.itemsView.viewHeight = bubbleHeight;
    self.contentView.viewHeight = self.itemsView.viewBottomEdge + kLGCellAvatarToVerticalEdgeSpacing;
    self.viewHeight = self.contentView.viewHeight;
}

#pragma lazy

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

@end
