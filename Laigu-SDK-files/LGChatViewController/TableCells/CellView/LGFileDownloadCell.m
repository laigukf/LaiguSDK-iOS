//
//  LGFileDownloadCell.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/4/6.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGFileDownloadCell.h"
#import "UIView+LGLayout.h"
#import "LGFileDownloadCellModel.h"
#import "LGChatViewConfig.h"
#import "LGImageUtil.h"
#import "LGChatViewConfig.h"
#import "LGAssetUtil.h"
#import "LGBundleUtil.h"
#import "LGWindowUtil.h"

@interface LGFileDownloadCell()<UIActionSheetDelegate>

@property (nonatomic, strong) LGFileDownloadCellModel *viewModel;

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UILabel *fileNameLabel;
@property (nonatomic, strong) UILabel *fileDetailLabel;
@property (nonatomic, strong) UIProgressView *downloadProgressBar;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *itemsView;
@property (nonatomic, strong) UITapGestureRecognizer *tagGesture;

@end

@implementation LGFileDownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.itemsView addSubview:self.icon];
        [self.itemsView addSubview:self.fileNameLabel];
        [self.itemsView addSubview:self.fileDetailLabel];
        [self.itemsView addSubview:self.actionButton];
        [self.itemsView addSubview:self.downloadProgressBar];
        
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.itemsView];
        
        [self updateUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateUI];
}

- (void)updateCellWithCellModel:(id<LGCellModelProtocol>)model {
    self.viewModel = model;
    
    [self updateUI];
    
    //user action callbacks
    __weak typeof (self)wself = self;
    
    [self.viewModel setNeedsToUpdateUI:^{
        __strong typeof (wself)sself = wself;
        [sself updateUI];
    }];
    
    [self.viewModel setAvatarLoaded:^(UIImage *image) {
        __strong typeof (wself)sself = wself;
        [sself.avatarImageView setImage:image];
    }];
    
    [self.viewModel setCellHeight:^CGFloat{
        __strong typeof (wself)sself = wself;
        [sself updateUI];
        return sself.viewHeight;
    }];
}

#pragma mark -

- (void)updateUI {
    LGFileDownloadStatus status = self.viewModel.fileDownloadStatus;
    
    //update UI contents according to status
    
    self.actionButton.hidden = (status == LGFileDownloadStatusDownloadComplete);
    self.downloadProgressBar.hidden = (status != LGFileDownloadStatusDownloading);
    
    CGFloat rightEdgeSpace = 5; //由于图片边界的原因，调整一下有图片和没有图片右边的距离，这样看起来协调一点.
    
    switch (status) {
        case LGFileDownloadStatusNotDownloaded: {
            [self.actionButton setImage:[LGAssetUtil fileDonwload] forState:UIControlStateNormal];
            if (self.viewModel.isExpired) {
                [self.fileDetailLabel setText:[NSString stringWithFormat:@"%@ ∙ %@",self.viewModel.fileSize, [LGBundleUtil localizedStringForKey:@"file_download_file_is_expired"]]];
            } else {
                [self.fileDetailLabel setText:[NSString stringWithFormat:[LGBundleUtil localizedStringForKey:@"file_download_ %@ ∙ %@overdue"], self.viewModel.fileSize, self.viewModel.timeBeforeExpire]];
            }
        }
        break;
        case LGFileDownloadStatusDownloading: {
            [self.actionButton setImage:[LGAssetUtil fileCancel] forState:UIControlStateNormal];
            self.downloadProgressBar.progress = 0;//表示开始下载
            [self.fileDetailLabel setText:[LGBundleUtil localizedStringForKey:@"file_download_downloading"]];
        }
        break;
        case LGFileDownloadStatusDownloadComplete: {
            [self.actionButton setImage:nil forState:UIControlStateNormal];
            [self.fileDetailLabel setText:[LGBundleUtil localizedStringForKey:@"file_download_complete"]];
            rightEdgeSpace = kLGCellBubbleToTextHorizontalLargerSpacing;
        }
        break;
    }
    
    [self.fileNameLabel setText:self.viewModel.fileName];
    [self.fileNameLabel sizeToFit];
    [self.fileDetailLabel sizeToFit];
    
    if (self.viewModel.avartarImage) {
        self.avatarImageView.image = self.viewModel.avartarImage;
    }
    
    //layout
    
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kLGCellAvatarToVerticalEdgeSpacing, kLGCellAvatarToHorizontalEdgeSpacing)];
    [self.itemsView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kLGCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    
    [self.icon align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kLGCellBubbleToTextHorizontalLargerSpacing, kLGCellBubbleToTextVerticalSpacing)];
    [self.fileNameLabel align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.icon.viewRightEdge + 5, self.icon.viewY)];
    
    [self.fileDetailLabel align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.fileNameLabel.viewX, self.fileNameLabel.viewBottomEdge + 5)];
    
    if (self.downloadProgressBar.isHidden) {
        self.downloadProgressBar.viewHeight = 0;
    } else {
        self.downloadProgressBar.viewHeight = 5;
    }
    
    CGFloat maxMiddleRightEdge = self.viewWidth - self.avatarImageView.viewRightEdge - !self.actionButton.isHidden * self.actionButton.viewWidth - kLGCellAvatarToVerticalEdgeSpacing - kLGCellBubbleMaxWidthToEdgeSpacing;
    CGFloat middlePartRightEdge = MIN(MAX(self.fileNameLabel.viewRightEdge, self.fileDetailLabel.viewRightEdge), maxMiddleRightEdge);
    self.fileNameLabel.viewWidth = maxMiddleRightEdge - self.fileNameLabel.viewX; // 防止文件名过长
    self.fileDetailLabel.viewWidth = maxMiddleRightEdge - self.fileDetailLabel.viewX;
    
    [self.downloadProgressBar align:ViewAlignmentTopLeft relativeToPoint:CGPointMake([LGChatViewConfig sharedConfig].bubbleImageStretchInsets.left, self.fileDetailLabel.viewBottomEdge + kLGCellBubbleToTextHorizontalSmallerSpacing)];
    
    [self.actionButton align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(middlePartRightEdge + 5, kLGCellBubbleToTextVerticalSpacing)];
    
    self.itemsView.viewWidth = middlePartRightEdge + (5 + self.actionButton.viewWidth) * !self.actionButton.isHidden + rightEdgeSpace;
    
    self.downloadProgressBar.viewWidth = self.itemsView.viewWidth - [LGChatViewConfig sharedConfig].bubbleImageStretchInsets.left - [LGChatViewConfig sharedConfig].bubbleImageStretchInsets.right;
    
    self.itemsView.viewHeight = self.downloadProgressBar.viewBottomEdge;

    self.contentView.viewHeight = self.itemsView.viewBottomEdge + kLGCellAvatarToVerticalEdgeSpacing;
    self.viewHeight = self.contentView.viewHeight;
}

///点击状态按钮和整个cell都会触发此方法
- (void)actionForActionButton:(id)sender {
    switch (self.viewModel.fileDownloadStatus) {
        case LGFileDownloadStatusNotDownloaded: {
            __weak typeof (self)wself = self;
            [self.viewModel startDownloadWitchProcess:^(CGFloat process) {
                __strong typeof (wself)sself = wself;
                if (process >= 0 && process < 100) {
                    [sself.downloadProgressBar setProgress:process];
                } else if (process == 100) {
                    [sself updateUI];
                    [self showActionSheet];
                } else {
                    [sself updateUI];
                }
            }];
        }
        break;
        case LGFileDownloadStatusDownloading: {
            if ([sender isKindOfClass:[UIButton class]]) { //取消操作只有在点击取消按钮时响应
                [self.viewModel cancelDownload];
            }
        }
        break;
        case LGFileDownloadStatusDownloadComplete: {
            [self showActionSheet];
        }
        break;
    }
}

- (void)showActionSheet {
    [self.window endEditing:YES];
    UIActionSheet *as = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:[LGBundleUtil localizedStringForKey:@"cancel"] destructiveButtonTitle:nil otherButtonTitles:[LGBundleUtil localizedStringForKey:@"lg_display_preview"],[LGBundleUtil localizedStringForKey:@"lg_open_file"], nil];

    as.delegate = self;
    [as showInView:self];
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.viewModel previewFileFromController:[LGWindowUtil topController]];
    } else if (buttonIndex == 1) {
        [self.viewModel openFile:self];
    }
}

#pragma mark - lazy load

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
        [_itemsView addGestureRecognizer:self.tagGesture];
    }
    return _itemsView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[LGAssetUtil fileIcon]];
        _icon.viewSize = CGSizeMake(kLGCellAvatarDiameter, kLGCellAvatarDiameter);
    }
    return _icon;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [UIButton new];
        _actionButton.viewSize = CGSizeMake(35, 35);
        [_actionButton addTarget:self action:@selector(actionForActionButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [UILabel new];
        _fileNameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _fileNameLabel;
}

- (UILabel *)fileDetailLabel {
    if (!_fileDetailLabel) {
        _fileDetailLabel = [UILabel new];
        _fileDetailLabel.font = [UIFont systemFontOfSize:12];
        _fileDetailLabel.textColor = [UIColor lightGrayColor];
        _fileDetailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _fileDetailLabel;
}

- (UIProgressView *)downloadProgressBar {
    if (!_downloadProgressBar) {
        _downloadProgressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    }
    
    return _downloadProgressBar;
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

- (UITapGestureRecognizer *)tagGesture {
    if (!_tagGesture) {
        _tagGesture = [UITapGestureRecognizer new];
        [_tagGesture addTarget:self action:@selector(actionForActionButton:)];
    }
    return _tagGesture;
}

@end
