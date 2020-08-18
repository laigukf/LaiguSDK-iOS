//
//  LGLog.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 16/6/1.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//


#ifndef LGLog_h
#define LGLog_h

#endif /* LGLog_h */

static BOOL LGIsLogEnabled = NO; //发布时默认关闭NO
#define FILENAME [[[NSString alloc] initWithUTF8String:__FILE__] lastPathComponent]

#define LGInfo(str, ...) {\
if(LGIsLogEnabled){\
NSLog(@"LaiGu [%@,%d]↓↓", FILENAME, __LINE__); \
NSLog(str, ##__VA_ARGS__);\
}\
}

#define LGError(str, ...){\
if(LGIsLogEnabled){\
NSLog(@"LaiGu [*ERROR*][%@,%d]☟☟", FILENAME, __LINE__); \
NSLog(str, ##__VA_ARGS__);\
}\
}
