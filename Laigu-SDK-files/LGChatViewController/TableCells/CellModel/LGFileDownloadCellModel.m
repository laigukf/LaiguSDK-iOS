//
//  LGFileDownloadCellModel.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/4/6.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGFileDownloadCellModel.h"
#import "LGFileDownloadMessage.h"
#import "LGChatFileUtil.h"
#import "LGFileDownloadCell.h"
#import "LGServiceToViewInterface.h"
#import "LGBundleUtil.h"
#import "LGToast.h"
#import <QuickLook/QuickLook.h>

@interface LGFileDownloadCellModel()<UIDocumentInteractionControllerDelegate, QLPreviewControllerDataSource>

@property (nonatomic, strong) LGFileDownloadMessage *message;
@property (nonatomic, copy) NSString *downloadingURL;

@end

@implementation LGFileDownloadCellModel

- (id)initCellModelWithMessage:(LGFileDownloadMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<LGCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        if ([LGChatFileUtil fileExistsAtPath:[self savedFilePath] isDirectory:NO]) {
            self.fileDownloadStatus = LGFileDownloadStatusDownloadComplete;
        }
        self.fileName = message.fileName;
        self.fileSize = [self fileSizeStringWithFileSize:(CGFloat)message.fileSize];
        if (message.expireDate.timeIntervalSinceReferenceDate > [NSDate new].timeIntervalSinceReferenceDate) {
            self.timeBeforeExpire = [NSString stringWithFormat:@"%.1f",(message.expireDate.timeIntervalSinceReferenceDate - [NSDate new].timeIntervalSinceReferenceDate) / 3600];
            self.isExpired = NO;
        } else {
            self.timeBeforeExpire = @"";
            self.isExpired = YES;
        }
        
        __weak typeof(self)wself = self;
        [LGServiceToViewInterface downloadMediaWithUrlString:message.userAvatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
            if (mediaData) {
                __strong typeof (wself) sself = wself;
                sself.avartarImage = [UIImage imageWithData:mediaData];
                if (sself.avatarLoaded) {
                    sself.avatarLoaded(sself.avartarImage);
                }
            }
        }];
    }
    return self;
}

- (NSString *)fileSizeStringWithFileSize:(CGFloat)fileSize {
    NSString *fileSizeString = [NSString stringWithFormat:@"%.1f MB", fileSize / 1024 / 1024];
    
    if (fileSizeString.floatValue < 1) {
        fileSizeString = [NSString stringWithFormat:@"%.1f KB", fileSize / 1024];
    }
    
    if (fileSizeString.floatValue < 1) {
        fileSizeString = [NSString stringWithFormat:@"%.0f B", fileSize];
    }
    
    return fileSizeString;
}

- (void)requestForFileURLComplete:(void(^)(NSString *url))action {
    BOOL isURLReady = NO;
    if ([self.message.filePath length] > 0) {
        isURLReady = YES;
        action(self.message.filePath);
    }
    
    //用于统计
    [LGServiceToViewInterface clientDownloadFileWithMessageId:self.message.messageId conversatioId:self.message.conversationId andCompletion:^(NSString *url, NSError *error) {
        if (!isURLReady) {
            action(url);
        }
    }];
}

- (void)startDownloadWitchProcess:(void(^)(CGFloat process))block {
    
    if (!block) {
        return;
    }
    
    if (self.isExpired) {
        [LGToast showToast:[LGBundleUtil localizedStringForKey:@"file_download_file_is_expired"] duration:2 window:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    self.fileDownloadStatus = LGFileDownloadStatusDownloading;
    if (self.needsToUpdateUI) {
        self.needsToUpdateUI();
    }
    block(0);
    
    [self requestForFileURLComplete:^(NSString *url) {
        url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        self.downloadingURL = url;
       [LGServiceToViewInterface downloadMediaWithUrlString:url progress:^(float progress) {
           self.fileDownloadStatus = LGFileDownloadStatusDownloading;
           block(progress);
       } completion:^(NSData *mediaData, NSError *error) {
           self.downloadingURL = nil;
           if (!error) {
               self.fileDownloadStatus = LGFileDownloadStatusDownloadComplete;
               self.file = mediaData;
               [self saveFile:mediaData];
               block(100);
           } else {
               [LGToast showToast:[NSString stringWithFormat:@"%@ %@",[LGBundleUtil localizedStringForKey:@"file_download_failed"],error.localizedDescription] duration:2 window:[UIApplication sharedApplication].keyWindow];
               self.fileDownloadStatus = LGFileDownloadStatusNotDownloaded;
               block(-1);
           }
       }];
    }];
}

- (void)cancelDownload {
    [LGToast showToast:[LGBundleUtil localizedStringForKey:@"file_download_canceld"] duration:2 window:[UIApplication sharedApplication].keyWindow];
    [LGServiceToViewInterface cancelDownloadForUrl:self.downloadingURL];
    self.downloadingURL = nil;
    self.fileDownloadStatus = LGFileDownloadStatusNotDownloaded;
    if (self.needsToUpdateUI) {
        self.needsToUpdateUI();
    }
}

- (void)openFile:(UIView *)sender {
    NSURL *url = [NSURL fileURLWithPath:[self savedFilePath]];
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    [interactionController setDelegate:self];
    [interactionController presentOptionsMenuFromRect:CGRectZero inView:sender.superview animated:YES];
}

- (void)previewFileFromController:(UIViewController *)controller {
    QLPreviewController *previewController = [QLPreviewController new];
    previewController.dataSource = self;
    previewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [controller presentViewController:previewController animated:YES completion:nil];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:[self savedFilePath]];
}

#pragma mark - private

- (NSString *)savedFilePath {
    return [DIR_RECEIVED_FILE stringByAppendingString:[self persistenceFileName]];
}

- (void)saveFile:(NSData *)data {
    [LGChatFileUtil saveFileWithName:[self persistenceFileName] data:data];
}

- (NSString *)persistenceFileName {
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",self.message.messageId, self.message.fileName];
    return fileName;
}

#pragma mark - delegate

- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 80;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (LGChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[LGFileDownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.message.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.message.messageId;
}

- (void)updateCellSendStatus:(LGChatMessageSendStatus)sendStatus {
    self.message.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.message.messageId = messageId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    if (self.needsToUpdateUI) {
        self.needsToUpdateUI();
    }
}

@end
