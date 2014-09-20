//
//  User.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeUser.h"
#import "DateConverter.h"

@implementation HandshakeUser

+ (HandshakeUser *)userFromDictionary:(NSDictionary *)dict {
    HandshakeUser *user = [[HandshakeUser alloc] init];
    user.userId = [[dict objectForKey:@"id"] longValue];
    user.createdAt = [DateConverter convertToDate:[dict objectForKey:@"created_at"]];
    user.updatedAt = [DateConverter convertToDate:[dict objectForKey:@"updated_at"]];
    user.email = [dict objectForKey:@"email"];
    user.confirmedAt = [DateConverter convertToDate:[dict objectForKey:@"confirmed_at"]];
    user.unconfirmedEmail = [dict objectForKey:@"unconfirmed_email"];
    if ([user.unconfirmedEmail isKindOfClass:[NSNull class]]) user.unconfirmedEmail = nil;
    user.confirmationSentAt = [DateConverter convertToDate:[dict objectForKey:@"confirmation_sent_at"]];
    return user;
}

@end
