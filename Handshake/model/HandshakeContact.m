//
//  Contact.m
//  Handshake
//
//  Created by Sam Ober on 9/13/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeContact.h"
#import "DateConverter.h"

@implementation HandshakeContact

+ (HandshakeContact *)contactFromDictionary:(NSDictionary *)dict {
    HandshakeContact *contact = [[HandshakeContact alloc] init];
    
    contact.contactId = [dict[@"id"] longValue];
    contact.createdAt = [DateConverter convertToDate:dict[@"created_at"]];
    contact.updatedAt = [DateConverter convertToDate:dict[@"updated_at"]];
    
    contact.card = [HandshakeCard cardFromDictionary:dict[@"card"]];
    contact.shake = [HandshakeShake shakeFromDictionary:dict[@"shake"]];
    
    return contact;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[HandshakeContact class]]) {
        return self.contactId == ((HandshakeContact *)object).contactId;
    } else return [super isEqual:object];
}

@end
