//
//  LGRecordView.m
//  LaiGuSDK
//
//  Created by zhangshunxing on 14/11/13.
//  Copyright (c) 2014年 LaiGu. All rights reserved.
//

#import "LGRecordView.h"
#import "LAIGU_FBLCDFontView.h"
#import "LGNamespacedDependencies.h"
#import "LGImageUtil.h"
#import "LGChatFileUtil.h"
#import "LGToast.h"
#import "LGChatAudioRecorder.h"
#import "LGAssetUtil.h"
#import "LGBundleUtil.h"
#import "LGChatViewConfig.h"

static CGFloat const kLGRecordViewDiameter = 150.0;
static CGFloat const kLGVolumeViewTopMargin = 16.0;
//最大时长的误差修正，这里主要是解决最大时长的文件读出的时长与配置最大市场不准确的问题；这里写的不好，请开发者指正；
static NSInteger const kLGMaxRecordVoiceDurationDeviation = 2;

@interface LGRecordView()<LGChatAudioRecorderDelegate>

@end

@implementation LGRecordView
{
    UIView* blurView;
    UIView* recordView;
    UIImageView* volumeView;
    UILabel* tipLabel;
    FBLCDFontView *LCDView;
    
    UIImage* blurImage;
    BOOL isVisible;
    
    CGFloat recordTime; //录音时长
    NSTimer *recordTimer;
    LGChatAudioRecorder *audioRecorder;
    NSInteger maxVoiceDuration;
}

-(instancetype)initWithFrame:(CGRect)frame maxRecordDuration:(NSTimeInterval)duration
{
    if (self = [super initWithFrame:frame]) {
        maxVoiceDuration = duration;
        self.revoke = NO;
        self.layer.masksToBounds = YES;
        recordView = [[UIView alloc] init];
        recordView.layer.cornerRadius = 10;
        recordView.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
        
        blurView = [[UIView alloc] init];
        volumeView = [[UIImageView alloc] init];
        
        tipLabel = [[UILabel alloc] init];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.font = [UIFont boldSystemFontOfSize:14];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        
        if ([LGChatViewConfig sharedConfig].enableVoiceRecordBlurView) {
            [self addSubview:blurView];
        }
        [self addSubview:recordView];
        [recordView addSubview:volumeView];
        [recordView addSubview:tipLabel];
        
        audioRecorder = [[LGChatAudioRecorder alloc] initWithMaxRecordDuration:duration+kLGMaxRecordVoiceDurationDeviation];
        audioRecorder.delegate = self;
    }
    return self;
}

- (void)setRecordMode:(LGRecordMode)recordMode {
    audioRecorder.recordMode = recordMode;
}

- (LGRecordMode)recordMode {
    return audioRecorder.recordMode;
}

- (void)setKeepSessionActive:(BOOL)keepSessionActive {
    audioRecorder.keepSessionActive = keepSessionActive;
}

- (BOOL)keepSessionActive {
    return audioRecorder.keepSessionActive;
}

-(void)setRevoke:(BOOL)revoke
{
    if (revoke != self.revoke) {
        if (revoke) {
            tipLabel.text = [LGBundleUtil localizedStringForKey:@"record_cancel_realse"];
            volumeView.image = [LGAssetUtil recordBackImage];
        }else{
            tipLabel.text = [LGBundleUtil localizedStringForKey:@"record_cancel_swipe"];
            volumeView.image = [LGAssetUtil recordVolume:0];
        }
    }
    _revoke = revoke;
}

-(void)setupUI
{
    recordView.frame = CGRectMake((self.frame.size.width - kLGRecordViewDiameter) / 2,
                                  (self.frame.size.height - kLGRecordViewDiameter) / 2,
                                  kLGRecordViewDiameter, kLGRecordViewDiameter);
    self.marginBottom = self.frame.size.height - recordView.frame.origin.y - recordView.frame.size.height;
    recordView.alpha = 0;
    
    tipLabel.text = [LGBundleUtil localizedStringForKey:@"record_cancel_swipe"];
    tipLabel.frame = CGRectMake(0, kLGRecordViewDiameter - 20 - 12, recordView.frame.size.width, 20);
    
    UIImage *volumeImage = [LGAssetUtil recordVolume:0];
    CGFloat volumeViewHeight = ceilf(recordView.frame.size.height * 4 / 7);
    CGFloat volumeViewWidth = ceilf(volumeImage.size.width / volumeImage.size.height * volumeViewHeight);
    volumeView.frame = CGRectMake(recordView.frame.size.width/2 - volumeViewWidth/2, kLGVolumeViewTopMargin, volumeViewWidth, volumeViewHeight);
    volumeView.image = [LGAssetUtil recordVolume:0];
    
    [UIView animateWithDuration:.2 animations:^{
        recordView.alpha = 1;
    }];
}

- (void)reDisplayRecordView {
    self.hidden = NO;
    if (![LGChatViewConfig sharedConfig].enableVoiceRecordBlurView) {
        return;
    }
    if ([recordView.superview isEqual:self]) {
        [recordView removeFromSuperview];
    }
    if ([blurView.superview isEqual:self]) {
        [blurView removeFromSuperview];
    }
    blurImage = [[LGImageUtil viewScreenshot:self.superview] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self addSubview:blurView];
    [self addSubview:recordView];
    blurView.frame = CGRectMake(0, 0, blurImage.size.width, blurImage.size.height);
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurView.layer.contents = (id)blurImage.CGImage;

    if (blurImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
            UIImage *blur = [LGImageUtil blurryImage:blurImage
                                       withBlurLevel:.2
                                       exclusionPath:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *transition = [CATransition animation];
                transition.duration = .2;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                
                [blurView.layer addAnimation:transition forKey:nil];
                blurView.layer.contents = (id)blur.CGImage;
                
                [self setNeedsLayout];
                [self layoutIfNeeded];
            });
        });
    }
}

//-(void)didMoveToSuperview
//{
//    if (!isVisible) {
//        [self setupUI];
//        isVisible = YES;
//    }
//}

-(void)startRecording
{
    if (!recordTimer) {
        recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recodTime) userInfo:nil repeats:YES];
    }
    recordTime = 0;
    [audioRecorder beginRecording];
}

-(void)recodTime
{
    recordTime = recordTime + 0.1;
    if (recordTime >= maxVoiceDuration + kLGMaxRecordVoiceDurationDeviation - 10) {
        volumeView.alpha = 0;
        if (LCDView) {
            [LCDView removeFromSuperview];
            LCDView = nil;
        }
        LCDView = [[FBLCDFontView alloc] initWithFrame:volumeView.frame];
        LCDView.lineWidth = 4.0;
        LCDView.drawOffLine = NO;
        LCDView.edgeLength = 30;
        LCDView.margin = 0.0;
        LCDView.backgroundColor = [UIColor clearColor];
        LCDView.horizontalPadding = 20;
        LCDView.verticalPadding = 14;
        LCDView.glowSize = 10.0;
        LCDView.glowColor = [UIColor whiteColor];
        LCDView.innerGlowColor = [UIColor grayColor];
        LCDView.innerGlowSize = 3.0;
        [recordView addSubview:LCDView];
        LCDView.text = [NSString stringWithFormat:@"%d",(int)(maxVoiceDuration + kLGMaxRecordVoiceDurationDeviation - recordTime)];
        [LCDView resetSize];
    }
    NSLog(@"recordView time = %f", recordTime);
}

-(void)setRecordingVolume:(float)volume
{
    if (!self.revoke) {
        if (volume > .66) {
            volumeView.image = [LGAssetUtil recordVolume:8];
        }else if (volume > .57){
            volumeView.image = [LGAssetUtil recordVolume:7];
        }else if (volume > .48){
            volumeView.image = [LGAssetUtil recordVolume:6];
        }else if (volume > .39){
            volumeView.image = [LGAssetUtil recordVolume:5];
        }else if (volume > .30){
            volumeView.image = [LGAssetUtil recordVolume:4];
        }else if (volume > .21){
            volumeView.image = [LGAssetUtil recordVolume:3];
        }else if (volume > .12){
            volumeView.image = [LGAssetUtil recordVolume:2];
        }else if (volume > .03){
            volumeView.image = [LGAssetUtil recordVolume:1];
        }else{
            volumeView.image = [LGAssetUtil recordVolume:0];
        }
    }
}

//组件终止录音
-(void)stopRecord
{
    if (recordTime < 1 && recordTime >= 0) {
        if (!self.hidden) {
            [LGToast showToast:[LGBundleUtil localizedStringForKey:@"recode_time_too_short"] duration:1 window:self.superview];
        }
        [audioRecorder cancelRecording];
    } else {
        [audioRecorder finishRecording];
    }
    [self setRecordViewToDefaultStatus];
}

//取消录音
- (void)cancelRecording {
    [self setRecordViewToDefaultStatus];
    [audioRecorder cancelRecording];
}

//将录音界面置为默认状态
- (void)setRecordViewToDefaultStatus {
    [recordTimer invalidate];
    recordTimer = nil;
    self.hidden = YES;
    recordTime = 0;
    if (LCDView) {
        [LCDView removeFromSuperview];
    }
    volumeView.alpha = 1.0;
    tipLabel.text = [LGBundleUtil localizedStringForKey:@"record_cancel_swipe"];
    volumeView.image = [LGAssetUtil recordVolume:0];
}

-(void)revokerecord {
    self.hidden = YES;
}

-(void)recordError:(NSError*)error
{
    self.hidden = YES;
}

#pragma LGChatAudioRecorderDelegate
- (void)didFinishRecordingWithAMRFilePath:(NSString *)filePath {
    //通知viewController已完成录音
    if (self.recordViewDelegate) {
        if ([self.recordViewDelegate respondsToSelector:@selector(didFinishRecordingWithAMRFilePath:)]) {
            [self.recordViewDelegate didFinishRecordingWithAMRFilePath:filePath];
        }
    }
    //恢复录音界面
    [self setRecordViewToDefaultStatus];
}

- (void)didUpdateAudioVolume:(Float32)volume {
//    [self setRecordingVolume:volume];
    if ([self.recordViewDelegate respondsToSelector:@selector(didUpdateVolumeInRecordView:volume:)]) {
        [self.recordViewDelegate didUpdateVolumeInRecordView:self volume:volume];
    }
}

- (void)didEndRecording {
    [self stopRecord];
}

- (void)didBeginRecording {
    
}

/** 更新frame */
- (void)updateFrame:(CGRect)frame {
    self.frame = frame;
    recordView.frame = CGRectMake((self.frame.size.width - kLGRecordViewDiameter) / 2,
                                  (self.frame.size.height - kLGRecordViewDiameter) / 2,
                                  kLGRecordViewDiameter, kLGRecordViewDiameter);

}

- (BOOL)isRecording {
    return [audioRecorder isRecording];
}

@end
