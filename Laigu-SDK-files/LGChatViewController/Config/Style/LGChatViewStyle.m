//
//  LGChatViewStyle.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/3/29.
//  Copyright © 2016年 zhangshunxing. All rights reserved.
//

#import "LGChatViewStyle.h"
#import "LGAssetUtil.h"
#import "LGChatViewStyleBlue.h"
#import "LGChatViewStyleGreen.h"
#import "LGChatViewStyleDark.h"

@interface LGChatViewStyle()

@property (nonatomic, assign) BOOL didSetStatusBarStyle;

@end

@implementation LGChatViewStyle

+ (instancetype)createWithStyle:(LGChatViewStyleType)type {
    switch (type) {
        case LGChatViewStyleTypeBlue:
            return [LGChatViewStyleBlue new];
        case LGChatViewStyleTypeGreen:
            return [LGChatViewStyleGreen new];
        case LGChatViewStyleTypeDark:
            return [LGChatViewStyleDark new];
        default:
            return [LGChatViewStyle new];
    }
}

+ (instancetype)defaultStyle {
    return [self createWithStyle:(LGChatViewStyleTypeDefault)];
}

+ (instancetype)blueStyle {
    return [self createWithStyle:(LGChatViewStyleTypeBlue)];
}

+ (instancetype)darkStyle {
    return [self createWithStyle:(LGChatViewStyleTypeDark)];
}

+ (instancetype)greenStyle {
    return [self createWithStyle:(LGChatViewStyleTypeGreen)];
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.enableRoundAvatar       = false;
        self.enableIncomingAvatar    = true;
        self.enableOutgoingAvatar    = true;

        self.backgroundColor = [UIColor whiteColor];
        self.incomingMsgTextColor   = [UIColor colorWithRed:90/255.0 green:105/255.0 blue:120/255.0 alpha:1];
        self.outgoingMsgTextColor   = [UIColor whiteColor];
        self.eventTextColor         = [UIColor grayColor];
        self.pullRefreshColor       = nil;//[UIColor colorWithRed:104.0/255.0 green:192.0/255.0 blue:160.0/255.0 alpha:1.0];
        self.btnTextColor            = [UIColor colorWithHexWithLong:0x3E8BFF];
        self.redirectAgentNameColor = [UIColor blueColor];
        self.navBarColor            = nil;//[UIColor colorWithHexString:LGBlueColor];
        self.navBarTintColor        = [UIColor colorWithHexWithLong:0x3E8BFF];

        self.incomingBubbleColor    = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:247/255.0 alpha:1];
        self.outgoingBubbleColor    = [UIColor colorWithRed:22/255.0 green:199/255.0 blue:209/255.0 alpha:1];
        self.navTitleColor          = nil;//[UIColor whiteColor];
        
        self.photoSenderImage               = [LGAssetUtil messageCameraInputImage];
        self.photoSenderHighlightedImage    = nil;
        self.keyboardSenderImage            = [LGAssetUtil messageTextInputImage];
        self.keyboardSenderHighlightedImage = nil;
        self.voiceSenderImage               = [LGAssetUtil messageVoiceInputImage];
        self.voiceSenderHighlightedImage    = nil;
        self.resignKeyboardImage            = [LGAssetUtil messageResignKeyboardImage];
        self.resignKeyboardHighlightedImage = nil;
        self.incomingBubbleImage            = [LGAssetUtil bubbleIncomingImage];
        self.outgoingBubbleImage            = [LGAssetUtil bubbleOutgoingImage];
        self.messageSendFailureImage        = [LGAssetUtil messageWarningImage];
        self.imageLoadErrorImage            = [LGAssetUtil imageLoadErrorImage];
        
        CGPoint stretchPoint                = CGPointMake(self.incomingBubbleImage.size.width / 4.0f, self.incomingBubbleImage.size.height * 3.0f / 4.0f);
        self.bubbleImageStretchInsets       = UIEdgeInsetsMake(stretchPoint.y, stretchPoint.x, self.incomingBubbleImage.size.height-stretchPoint.y+0.5, stretchPoint.x);
                
        self.statusBarStyle                 = UIStatusBarStyleDefault;
        self.didSetStatusBarStyle = false;
    }
    return self;
}


- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    _statusBarStyle = statusBarStyle;
    self.didSetStatusBarStyle = YES;
}

@end
