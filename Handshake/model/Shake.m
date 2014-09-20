//
//  Shake.m
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Shake.h"
#import "Contact.h"
#import "DateConverter.h"

@implementation Shake

@dynamic createdAt;
@dynamic latitude;
@dynamic location;
@dynamic longitude;
@dynamic shakeId;
@dynamic time;
@dynamic updatedAt;
@dynamic contact;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.shakeId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.time = [DateConverter convertUnixToDate:[dictionary[@"time"] longValue]];
    self.latitude = dictionary[@"latitude"];
    self.longitude = dictionary[@"longitude"];
    self.location = dictionary[@"location"];
}

@end
