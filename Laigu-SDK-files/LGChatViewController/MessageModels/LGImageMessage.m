//
//  LGImageMessage.m
//  LGChatViewControllerDemo
//
//  Created by zhangshunxing on 15/10/30.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import "LGImageMessage.h"

@implementation LGImageMessage

- (instancetype)init{
    if (self = [super init]) {
        self.imagePath = @"";
    }
    return self;
}

- (instancetype)initWithImagePath:(NSString *)imagePath {
    self = [self init];
    self.imagePath = imagePath;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [self init];
    self.image = image;
    return self;
}

@end
