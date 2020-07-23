//
//  LGPhotoCardMessage.h
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 ijinmao. All rights reserved.
//

#import "LGBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface LGPhotoCardMessage : LGBaseMessage

@property (nonatomic, copy) NSString *imagePath;

@property (nonatomic, copy) NSString *targetUrl;


-(instancetype)initWithImagePath:(NSString *)path andUrlPath:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
