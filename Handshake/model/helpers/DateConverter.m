//
//  DateConverter.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "DateConverter.h"

@implementation DateConverter

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *df = nil;
    
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        //[df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        //NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        //[df setLocale:locale];
    }
    
    return df;
}

+ (NSDate *)convertToDate:(NSString *)time {
    if ([time isKindOfClass:[NSNull class]]) return nil;
    
    //time = [time substringToIndex:19];
    return [[DateConverter dateFormatter] dateFromString:time];
}

+ (NSDate *)convertUnixToDate:(long long)time {
    return [NSDate dateWithTimeIntervalSince1970:((double)(time / 1000))];
}

+ (NSString *)convertToString:(NSDate *)date {
    return [[DateConverter dateFormatter] stringFromDate:date];
}

@end
