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

static BOOL syncing = NO;

@implementation Contact

@dynamic contactId;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic user;
@dynamic syncStatus;
@dynamic feedItems;

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    if (syncing)
        return;
    
    syncing = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // get most recent Contact
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
        request.fetchLimit = 1;
        [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]]];
        
        __block NSArray *results;
        
        __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        [objectContext performBlockAndWait:^{
            NSError *error;
            results = [objectContext executeFetchRequest:request error:&error];
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
            
            // reload context
            objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
            
            __block NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"syncStatus!=%@", [NSNumber numberWithInt:ContactSynced]];
            
            [objectContext performBlockAndWait:^{
                NSError *error;
                results = [objectContext executeFetchRequest:request error:&error];
            }];
            
            if (!results) {
                // error - stop sync
                dispatch_async(dispatch_get_main_queue(), ^{
                    syncing = NO;
                    if (completionBlock) completionBlock();
                });
                return;
            }
            
            NSMutableArray *operations = [[NSMutableArray alloc] init];
           
            for (Contact *contact in results) {
                if ([contact.syncStatus intValue] == ContactDeleted) {
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"DELETE" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/contacts/%d", [contact.contactId intValue]]] absoluteString] parameters:[[HandshakeSession currentSession] credentials] error:nil]];
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                    operation.responseSerializer = [HandshakeClient client].responseSerializer;
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [objectContext deleteObject:contact];
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
                    [objectContext performBlockAndWait:^{
                        [objectContext save:nil];
                    }];
                    [[HandshakeCoreDataStore defaultStore] saveMainContext];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // end sync
                        syncing = NO;
                        if (completionBlock) completionBlock();
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:ContactSyncCompleted object:nil];
                    });
                });
            }];
            [[[NSOperationQueue alloc] init] addOperations:preparedOperations waitUntilFinished:NO];
        }];
    });
}

+ (void)syncContactsOnPage:(int)page fromDate:(NSDate *)date finishedBlock:(void (^)())finishedBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
        params[@"page"] = [[NSNumber numberWithInt:page] stringValue];
        if (date)
            params[@"since_date"] = [DateConverter convertToString:date];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"GET" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:@"contacts"] absoluteString] parameters:params error:nil]];
        operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        operation.responseSerializer = [HandshakeClient client].responseSerializer;
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
            
            __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
            
            [objectContext performBlockAndWait:^{
                NSError *error;
                results = [objectContext executeFetchRequest:request error:&error];
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
                    [objectContext deleteObject:contact];
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
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:objectContext];
                Contact *contact = [[Contact alloc] initWithEntity:entity insertIntoManagedObjectContext:objectContext];
                
                [contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:contacts[contactId]]];
                contact.syncStatus = [NSNumber numberWithInt:ContactSynced];
            }
            
            // save context
            [objectContext performBlockAndWait:^{
                [objectContext save:nil];
            }];
            [[HandshakeCoreDataStore defaultStore] saveMainContext];
            
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
                    syncing = NO;
                    [[HandshakeSession currentSession] invalidate];
                } else {
                    // retry
                    [self syncContactsOnPage:page fromDate:date finishedBlock:finishedBlock];
                }
            });
        }];
        [[[NSOperationQueue alloc] init] addOperation:operation];
    });
}

+ (BOOL)syncing {
    return syncing;
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [self willChangeValueForKey:@"firstLetter"];
    
    self.contactId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    
    // find and update user
    
    if (self.user) {
        [self.user updateFromDictionary:dictionary[@"user"]];
    } else {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", dictionary[@"user"][@"id"]];
        request.fetchLimit = 1;
        
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (results && [results count] > 0) {
            User *user = (User *)results[0];
            [user updateFromDictionary:dictionary[@"user"]];
            self.user = user;
        } else {
            User *user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
            [user updateFromDictionary:dictionary[@"user"]];
            self.user = user;
        }
    }
    
    [self didChangeValueForKey:@"firstLetter"];
}

- (NSString *)firstLetter {
    [self willAccessValueForKey:@"firstLetter"];
    NSString *letter = [self.user firstLetterOfName];
    [self didAccessValueForKey:@"firstLetter"];
    return letter;
}

@end