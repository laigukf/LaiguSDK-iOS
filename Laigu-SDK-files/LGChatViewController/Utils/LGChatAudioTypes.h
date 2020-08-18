//
//  AudioTypes.h
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/4/19.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#ifndef AudioTypes_h
#define AudioTypes_h


#endif /* AudioTypes_h */

#import <AVFoundation/AVFoundation.h>

///控制声音播放的模式
typedef NS_ENUM(NSUInteger, LGPlayMode) {
    LGPlayModePauseOther = 0, //暂停其他音频
    LGPlayModeMixWithOther = AVAudioSessionCategoryOptionMixWithOthers, //和其他音频同时播放
    LGPlayModeDuckOther = AVAudioSessionCategoryOptionDuckOthers //降低其他音频的声音
};


///控制声音录制的模式
typedef NS_ENUM(NSUInteger, LGRecordMode) {
    LGRecordModePauseOther = 0, //暂停其他音频
    LGRecordModeMixWithOther = AVAudioSessionCategoryOptionMixWithOthers, //和其他音频同时播放
    LGRecordModeDuckOther = AVAudioSessionCategoryOptionDuckOthers //降低其他音频的声音
};
