//
//  LGChatAudioRecorder.h
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/11/2.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGChatAudioTypes.h"

@protocol LGChatAudioRecorderDelegate <NSObject>

/**
 * 完成录音的回调
 * @param filePath AMR数据格式的音频数据的文件
 */
- (void)didFinishRecordingWithAMRFilePath:(NSString *)filePath;

/** 
 * 音频音量有更新
 * @param volume 音量
 */
- (void)didUpdateAudioVolume:(Float32)volume;

/**
 * 录音开始的回调
 */
- (void)didBeginRecording;

/**
 * 录音结束的回调
 */
- (void)didEndRecording;

@end


@interface LGChatAudioRecorder : NSObject

@property (nonatomic ,weak) id<LGChatAudioRecorderDelegate> delegate;
///如果应用中有其他地方正在播放声音，比如游戏，需要将此设置为 YES，防止其他声音在录音播放完之后无法继续播放
@property (nonatomic, assign) BOOL keepSessionActive;
@property (nonatomic, assign) LGRecordMode recordMode;

- (void)beginRecording;

- (void)finishRecording;

- (void)cancelRecording;

- (BOOL)isRecording;

- (instancetype)initWithMaxRecordDuration:(NSTimeInterval)duration;

@end
