//
//  User.m
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "User.h"
#import "DateConverter.h"
#import "Card.h"

@implementation User

@dynamic confirmationSentAt;
@dynamic confirmedAt;
@dynamic createdAt;
@dynamic email;
@dynamic unconfirmedEmail;
@dynamic updatedAt;
@dynamic userId;
@dynamic cards;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.userId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.email = dictionary[@"email"];
    self.confirmedAt = [DateConverter convertToDate:dictionary[@"confirmed_at"]];
    self.unconfirmedEmail = dictionary[@"unconfirmed_email"];
    self.confirmationSentAt = [DateConverter convertToDate:dictionary[@"confirmation_sent_at"]];
}

@end
