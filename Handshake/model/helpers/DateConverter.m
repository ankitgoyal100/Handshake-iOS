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
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        //[df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        //NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        //[df setLocale:locale];
    }
    
    return df;
}

+ (NSDate *)convertToDate:(NSString *)time {
    if ([time isKindOfClass:[NSNull class]]) return nil;
    
    time = [time substringToIndex:19];
    return [[DateConverter dateFormatter] dateFromString:time];
}

+ (NSDate *)convertUnixToDate:(long)time {
    return [NSDate dateWithTimeIntervalSince1970:((double)time / 1000)];
}

@end
