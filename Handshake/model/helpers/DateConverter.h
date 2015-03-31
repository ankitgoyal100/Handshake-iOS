//
//  DateConverter.h
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateConverter : NSObject

+ (NSDate *)convertToDate:(NSString *)time;
+ (NSDate *)convertUnixToDate:(long long)time;

+ (NSString *)convertToString:(NSDate *)date;

@end
