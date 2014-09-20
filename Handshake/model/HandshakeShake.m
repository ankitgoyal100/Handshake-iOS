//
//  Shake.m
//  Handshake
//
//  Created by Sam Ober on 9/13/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeShake.h"
#import "DateConverter.h"

@implementation HandshakeShake

+ (HandshakeShake *)shakeFromDictionary:(NSDictionary *)dict {
    HandshakeShake *shake = [[HandshakeShake alloc] init];
    
    shake.shakeId = [dict[@"id"] longValue];
    shake.createdAt = [DateConverter convertToDate:dict[@"created_at"]];
    shake.updatedAt = [DateConverter convertToDate:dict[@"updated_at"]];
    shake.time = [DateConverter convertUnixToDate:[dict[@"time"] longValue]];
    shake.latitude = [dict[@"lat"] doubleValue];
    shake.longitude = [dict[@"long"] doubleValue];
    shake.location = dict[@"location"];
    if ([shake.location isKindOfClass:[NSNull class]]) shake.location = nil;
    
    return shake;
}

@end
