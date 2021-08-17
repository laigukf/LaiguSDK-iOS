//
//  LGNewRichText1.m
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 2020/5/12.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import "LGBotMenuRichMessageCell.h"
#import "LGChatViewConfig.h"
#import "UIView+LGLayout.h"
#import "LGCellModelProtocol.h"
#import "LGImageUtil.h"
#import "LGBotMenuMessage.h"
#import "LGBotMenuRichCellModel.h"

static CGFloat const kLGBotMenuReplyTipSize = 12.0; // 查看提醒的文字大小
static NSString * const kLGBotMenuTipText = @"点击问题或回复对应数字查看答案"; // 提示文字内容

static CGFloat const kLGBotMenuTextSize = 15.0;// 答案列表文字

static CGFloat const kLGBotMenuVerticalSpacingInMenus = 12.0;


@interface LGBotMenuRichMessageCell()
{
    NSMutableArray *menuButtons;
}

@property (nonatomic, strong) LGBotMenuRichCellModel *viewModel;
@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) LGEmbededWebView *contentWebView;
@property (nonatomic, strong) UIView *itemsView;
@property (nonatomic, strong) UILabel *replyTipLabel;

@end

@implementation LGBotMenuRichMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.bubbleImageView];
        [self.bubbleImageView addSubview:self.contentWebView];
        [self.bubbleImageView addSubview:self.itemsView];
        [self.bubbleImageView addSubview:self.replyTipLabel];

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
            return sself.viewModel.cachedWetViewHeight + kLGCellAvatarToVerticalEdgeSpacing + kLGCellAvatarToVerticalEdgeSpacing + 120;
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
    
    
    NSArray *menuTitles = self.viewModel.message.menu;
    NSInteger menuNum = [menuTitles count];
    for (UIButton *btn in menuButtons) {
        [btn removeFromSuperview];
    }
    menuButtons = [NSMutableArray new];
    CGFloat menuOrigin = kLGCellBubbleToTextVerticalSpacing;
    CGFloat maxLabelWidth = 280;

    for (NSInteger i = 0; i < menuNum; i++) {
        UIButton *menuButton = [UIButton new];
        [menuButton setTitle:[menuTitles objectAtIndex:i] forState:UIControlStateNormal];
        [menuButton setFrame:CGRectMake(kLGCellBubbleToTextHorizontalLargerSpacing, menuOrigin, maxLabelWidth - 2*kLGCellBubbleToTextHorizontalLargerSpacing, 16)];
        menuOrigin += 16 + kLGBotMenuVerticalSpacingInMenus;
        [menuButton setTitleColor:[LGChatViewConfig sharedConfig].chatViewStyle.btnTextColor forState:UIControlStateNormal];
        menuButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [menuButton addTarget:self action:@selector(tapMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
        menuButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        menuButton.titleLabel.numberOfLines = 0;
        menuButton.titleLabel.font = [UIFont systemFontOfSize:kLGBotMenuTextSize];
        [menuButtons addObject:menuButton];
        [_itemsView addSubview:menuButton];
    }
    self.bubbleImageView.backgroundColor = UIColor.yellowColor;
    self.itemsView.frame = CGRectMake(0, 200, self.contentWebView.viewWidth, 120);
    self.bubbleImageView.frame = CGRectMake(0, 0, maxLabelWidth, 340);

    
//    _contentWebView.frame = CGRectMake(0, kLGCellBubbleToTextVerticalSpacing, maxLabelWidth, 0);
//    _itemsView.frame = CGRectMake(0, _contentWebView.viewBottomEdge, maxLabelWidth, menuOrigin);
//
    
    if (menuNum > 0) {
        self.replyTipLabel.hidden = false;
    }


    [self.viewModel bind];
}

- (void)layoutUI {
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarToVerticalEdgeSpacing)];
    [self.bubbleImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kLGCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    self.bubbleImageView.viewWidth = self.contentView.viewWidth - kLGCellBubbleMaxWidthToEdgeSpacing - self.avatarImageView.viewRightEdge;
    
    self.contentWebView.viewWidth = self.bubbleImageView.viewWidth - 8;
    self.contentWebView.viewX = 8;
    
}

- (void)updateUI:(CGFloat)webContentHeight {
    CGFloat bubbleHeight = MAX(self.avatarImageView.viewHeight, webContentHeight);
    
    self.contentWebView.viewHeight = bubbleHeight;
//    self.itemsView.viewHeight =
    self.itemsView.viewY = self.contentWebView.viewBottomEdge;
//    self.bubbleImageView.viewHeight = self.itemsView.viewBottomEdge;
    self.contentView.viewHeight = self.bubbleImageView.viewBottomEdge + kLGCellAvatarToVerticalEdgeSpacing;
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

- (UIImageView *)bubbleImageView {
    if (!_bubbleImageView) {
        _bubbleImageView = [UIImageView new];
        _bubbleImageView.userInteractionEnabled = true;
        UIImage *bubbleImage = [LGChatViewConfig sharedConfig].incomingBubbleImage;
        if ([LGChatViewConfig sharedConfig].incomingBubbleColor) {
            bubbleImage = [LGImageUtil convertImageColorWithImage:bubbleImage toColor:[LGChatViewConfig sharedConfig].incomingBubbleColor];
        }
        bubbleImage = [bubbleImage resizableImageWithCapInsets:[LGChatViewConfig sharedConfig].bubbleImageStretchInsets];
        _bubbleImageView.image = bubbleImage;
        _bubbleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _bubbleImageView;
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

- (UILabel *)replyTipLabel{
    if (!_replyTipLabel) {
        _replyTipLabel = [UILabel new];
        _replyTipLabel.textColor = [UIColor colorWithWhite:.6 alpha:1];
        _replyTipLabel.text = kLGBotMenuTipText;
        _replyTipLabel.textAlignment = NSTextAlignmentLeft;
        _replyTipLabel.font = [UIFont systemFontOfSize:kLGBotMenuReplyTipSize];
        _replyTipLabel.hidden = false;
    }
    return _replyTipLabel;
}

@end
