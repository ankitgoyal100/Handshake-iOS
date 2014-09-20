//
//  Contact.h
//  Handshake
//
//  Created by Sam Ober on 9/13/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandshakeCard.h"
#import "HandshakeShake.h"

@interface HandshakeContact : NSObject

@property (nonatomic) long contactId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@property (nonatomic, strong) HandshakeCard *card;
@property (nonatomic, strong) HandshakeShake *shake;

+ (HandshakeContact *)contactFromDictionary:(NSDictionary *)dict;

@end
