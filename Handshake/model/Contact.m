//
//  Contact.m
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Contact.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "HandshakeCoreDataStore.h"
#import "DateConverter.h"

@implementation Contact

@dynamic contactId;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic card;
@dynamic shake;
@dynamic syncStatus;

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    static BOOL syncing = NO;
    
    if (!syncing) {
        syncing = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // get most recent Contact
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
            request.fetchLimit = 1;
            [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]]];
            
            __block NSArray *results;
            
            [[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext] performBlockAndWait:^{
                NSError *error;
                results = [[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext] executeFetchRequest:request error:&error];
            }];
            
            if (!results) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    syncing = NO;
                    if (completionBlock) completionBlock();
                });
                return;
            }
            
            NSDate *checkDate = nil;
            
            if ([results count] > 0)
                checkDate = ((Contact *)results[0]).updatedAt;
            
            [self syncContactsOnPage:1 fromDate:checkDate finishedBlock:^{
                // sync current contacts
                
                __block NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
                
                request.predicate = [NSPredicate predicateWithFormat:@"syncStatus!=%@", [NSNumber numberWithInt:ContactSynced]];
                
                [[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext] performBlockAndWait:^{
                    NSError *error;
                    results = [[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext] executeFetchRequest:request error:&error];
                }];
                
                if (!results) {
                    // error - stop sync
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) completionBlock();
                    });
                    return;
                }
                
                NSMutableArray *operations = [[NSMutableArray alloc] init];
               
                for (Contact *contact in results) {
                    if ([contact.syncStatus intValue] == ContactDeleted) {
                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[AFHTTPRequestSerializer serializer] requestWithMethod:@"DELETE" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/contacts/%d", [contact.contactId intValue]]] absoluteString] parameters:[HandshakeSession credentials] error:nil]];
                        operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                        operation.responseSerializer = [AFJSONResponseSerializer serializer];
                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            [[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext] deleteObject:contact];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            // do nothing
                        }];
                        [operations addObject:operation];
                    }
                }
                
                NSArray *preparedOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                    // do nothing
                } completionBlock:^(NSArray *operations) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        // save
                        [[HandshakeCoreDataStore defaultStore] saveBackgroundContext];
                        [[HandshakeCoreDataStore defaultStore] saveMainContext];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // end sync
                            syncing = NO;
                            if (completionBlock) completionBlock();
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:ContactSyncCompleted object:nil];
                        });
                    });
                }];
                [[NSOperationQueue mainQueue] addOperations:preparedOperations waitUntilFinished:NO];
            }];
        });
    }
}

+ (void)syncContactsOnPage:(int)page fromDate:(NSDate *)date finishedBlock:(void (^)())finishedBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[HandshakeSession credentials]];
        params[@"page"] = [[NSNumber numberWithInt:page] stringValue];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:@"/contacts"] absoluteString] parameters:params error:nil]];
        operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // map objects to ids
            NSMutableDictionary *contacts = [[NSMutableDictionary alloc] init];
            for (NSDictionary *contactDict in responseObject[@"contacts"]) {
                contacts[contactDict[@"id"]] = contactDict;
            }
            
            // request contacts with ids
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"%K IN %@", @"contactId", [contacts allKeys]];
            
            __block NSArray *results;
            
            [[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext] performBlockAndWait:^{
                NSError *error;
                results = [[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext] executeFetchRequest:request error:&error];
            }];
            
            if (!results) {
                if (finishedBlock) finishedBlock();
                return;
            }
            
            for (Contact *contact in results) {
                // update/delete contact and remove from list
                NSDictionary *contactDict = contacts[contact.contactId];
                [contacts removeObjectForKey:contact.contactId];
                
                if ([contactDict[@"is_deleted"] boolValue]) {
                    // delete
                    [[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext] deleteObject:contact];
                } else {
                    // update if contact is newer
                    if ([[DateConverter convertToDate:contactDict[@"updated_at"]] timeIntervalSinceDate:contact.updatedAt] > 0) {
                        [contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:contactDict]];
                        contact.syncStatus = [NSNumber numberWithInt:ContactSynced];
                    }
                }
            }
            
            // all left over are new contacts unless they are deleted
            for (NSNumber *contactId in [contacts allKeys]) {
                if ([contacts[contactId][@"is_deleted"] boolValue]) continue;
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext]];
                Contact *contact = [[Contact alloc] initWithEntity:entity insertIntoManagedObjectContext:[[HandshakeCoreDataStore defaultStore] backgroundManagedObjectContext]];
                
                [contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:contacts[contactId]]];
                contact.syncStatus = [NSNumber numberWithInt:ContactSynced];
            }
            
            // check if last page (< 200 contacts returned)
            if ([responseObject[@"contacts"] count] < 200) {
                if (finishedBlock) finishedBlock();
                return;
            }
            
            // get next page of contacts
            [self syncContactsOnPage:page + 1 fromDate:date finishedBlock:finishedBlock];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[operation response] statusCode] == 401) {
                    finishedBlock();
                    [HandshakeSession invalidate];
                } else {
                    // retry
                    [self syncContactsOnPage:page fromDate:date finishedBlock:finishedBlock];
                }
            });
        }];
        [[NSOperationQueue mainQueue] addOperation:operation];
    });
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.contactId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.managedObjectContext];
    Card *card = [[Card alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    
    if (self.card) [self.managedObjectContext deleteObject:self.card];
    [card updateFromDictionary:dictionary[@"card"]];
    self.card = card;
    
    entity = [NSEntityDescription entityForName:@"Shake" inManagedObjectContext:self.managedObjectContext];
    Shake *shake = [[Shake alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    
    if (self.shake) [self.managedObjectContext deleteObject:self.shake];
    [shake updateFromDictionary:dictionary[@"shake"]];
    self.shake = shake;
}

@end
