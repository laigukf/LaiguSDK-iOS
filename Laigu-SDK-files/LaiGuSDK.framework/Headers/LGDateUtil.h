//
//  LGDate.h
//  LaiGuSDK
//
//  Created by zhangshunxing on 15/10/24.
//  Copyright © 2015年 LaiGu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGDateUtil : NSObject

+ (NSString *)iso8601StringFromUTCDate:(NSDate *)date;
+ (NSDate *)convertToUtcDateFromUTCDateString:(NSString *)dateString;

+ (NSDate *)convertToLoaclDateFromUTCDate:(NSDate *)anyDate;
+ (NSDate *)convertToUTCDateFromLocalDate:(NSDate *)fromDate;

@end
