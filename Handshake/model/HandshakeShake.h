//
//  Shake.h
//  Handshake
//
//  Created by Sam Ober on 9/13/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandshakeShake : NSObject

@property (nonatomic) long shakeId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, strong) NSString *location;

+ (HandshakeShake *)shakeFromDictionary:(NSDictionary *)dict;

@end
