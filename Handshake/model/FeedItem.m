//
//  FeedItem.m
//  Handshake
//
//  Created by Sam Ober on 6/1/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "FeedItem.h"
#import "Contact.h"
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
@dynamic contact;
@dynamic group;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.feedId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.itemType = dictionary[@"item_type"];
    
    if (dictionary[@"contact"]) {
        // find contact
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"contactId == %@", dictionary[@"contact"][@"id"]];
        request.fetchLimit = 1;
        
        __block NSArray *results;
        
        [self.managedObjectContext performBlockAndWait:^{
            NSError *error;
            results = [self.managedObjectContext executeFetchRequest:request error:&error];
        }];
        
        if (results && [results count] == 1) {
            self.contact = results[0];
        } else {
//            self.contact = [[Contact alloc] initWithEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
//            
//            [self.contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:dictionary[@"contact"]]];
//            self.contact.updatedAt = [NSDate dateWithTimeIntervalSince1970:0]; // avoid messing with the Contact sync which uses the most recent updatedAt
//            
//            if (dictionary[@"contact"][@"is_deleted"]) self.contact.syncStatus = @(ContactDeleted);
        }
    }
    
    if (dictionary[@"group"]) {
        // find group
        
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

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        // delete all feed items
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FeedItem"];
        
        __block NSArray *results;
        
        [objectContext performBlockAndWait:^{
            NSError *error;
            results = [objectContext executeFetchRequest:request error:&error];
        }];
        
        for (FeedItem *item in results)
            [objectContext deleteObject:item];
        
        [self syncPage:1 objectContext:objectContext completionBlock:^{
            if (completionBlock) completionBlock();
        }];
    });
}

+ (void)syncPage:(int)page objectContext:(NSManagedObjectContext *)objectContext completionBlock:(void (^)())completionBlock {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"page"] = @(page);
    
    [[HandshakeClient client] GET:@"/feed" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"feed"] count] == 0) {
            if (completionBlock) completionBlock();
            return;
        }
        
        for (NSDictionary *dict in responseObject[@"feed"]) {
            NSDictionary *feedDict = [HandshakeCoreDataStore removeNullsFromDictionary:dict];
            
            // find/create feed item
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FeedItem"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"feedId == %@", feedDict[@"id"]];
            request.fetchLimit = 1;
            
            __block NSArray *results;
            
            [objectContext performBlockAndWait:^{
                NSError *error;
                results = [objectContext executeFetchRequest:request error:&error];
            }];
            
            FeedItem *item;
            
            if (results && [results count] == 1) {
                item = results[0];
            } else {
                item = [[FeedItem alloc] initWithEntity:[NSEntityDescription entityForName:@"FeedItem" inManagedObjectContext:objectContext] insertIntoManagedObjectContext:objectContext];
            }
            
            [item updateFromDictionary:feedDict];
        }
        
        // save context
        [objectContext performBlockAndWait:^{
            [objectContext save:nil];
        }];
        
        [self syncPage:page + 1 objectContext:objectContext completionBlock:completionBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            [[HandshakeSession currentSession] invalidate];
        } else {
            if (completionBlock) completionBlock();
        }
    }];
}

@end
