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
    
    if (dictionary[@"user"]) {
        // find or create user
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", dictionary[@"user"][@"id"]];
        request.fetchLimit = 1;
        
        __block NSArray *results;
        
        [self.managedObjectContext performBlockAndWait:^{
            NSError *error;
            results = [self.managedObjectContext executeFetchRequest:request error:&error];
        }];
        
        if (results && [results count] == 1)
            self.user = results[0];
        else
            self.user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        [self.user updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:dictionary[@"user"]]];
    }
    
    if (dictionary[@"group"]) {
        // find or create group
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"groupId == %@", dictionary[@"group"][@"id"]];
        request.fetchLimit = 1;
        
        __block NSArray *results;
        
        [self.managedObjectContext performBlockAndWait:^{
            NSError *error;
            results = [self.managedObjectContext executeFetchRequest:request error:&error];
        }];
        
        if (results && [results count] == 1) {
            self.group = results[0];
        }
    }
}

@end
