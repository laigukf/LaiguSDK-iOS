//
//  LGPhotoCardMessage.m
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import "LGPhotoCardMessage.h"

@implementation LGPhotoCardMessage

-(instancetype)initWithImagePath:(NSString *)path andUrlPath:(NSString *)url {
    if (self = [super init]) {
        self.imagePath = path;
        self.targetUrl  = url;
    }
    return self;
}


@end
