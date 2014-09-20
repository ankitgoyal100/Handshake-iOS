//
//  Address.h
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandshakeAddress : NSObject

- (id)initWithStreet1:(NSString *)street1 street2:(NSString *)street2 city:(NSString *)city state:(NSString *)state zip:(NSString *)zip label:(NSString *)label;

- (NSString *)formattedString;

@property (nonatomic, strong) NSString *street1;
@property (nonatomic, strong) NSString *street2;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *label;

@end
