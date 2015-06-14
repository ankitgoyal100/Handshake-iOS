//
//  FeedItem.m
//  Handshake
//
//  Created by Sam Ober on 6/1/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "FeedItem.h"
#import "User.h"
#import "Group.h"
#import "DateConverter.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"

@implementation FeedItem

@dynamic feedId;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic itemType;
@dynamic user;
@dynamic group;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.feedId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.itemType = dictionary[@"item_type"];
}

@end
