//
//  ContactServerSync.m
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "ContactServerSync.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "ContactSync.h"
#import "DateConverter.h"
#import "FeedItem.h"

@implementation ContactServerSync

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // get most recent Contact
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"isContact == %@", @(YES)];
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
                if (completionBlock) completionBlock();
            });
            return;
        }
        
        NSDate *checkDate = nil;
        
        if ([results count] > 0)
            checkDate = ((User *)results[0]).contactUpdated;
        
        [self syncPage:1 fromDate:checkDate finishedBlock:^{
            // sync current contacts
            
            // reload context
            objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
            
            __block NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"syncStatus != %@", @(UserSynced)];
            
            [objectContext performBlockAndWait:^{
                NSError *error;
                results = [objectContext executeFetchRequest:request error:&error];
            }];
            
            if (!results) {
                // error - stop sync
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock();
                });
                return;
            }
            
            NSMutableArray *operations = [[NSMutableArray alloc] init];
            
            for (User *contact in results) {
                if ([contact.syncStatus intValue] == UserDeleted) {
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"DELETE" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/users/%d", [contact.userId intValue]]] absoluteString] parameters:[[HandshakeSession currentSession] credentials] error:nil]];
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                    operation.responseSerializer = [HandshakeClient client].responseSerializer;
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
                        contact.syncStatus = @(UserSynced);
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
                    
                    [ContactSync sync];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // end sync
                        if (completionBlock) completionBlock();
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:ContactSyncCompleted object:nil];
                    });
                });
            }];
            [[[NSOperationQueue alloc] init] addOperations:preparedOperations waitUntilFinished:NO];
        }];
    });
}

+ (void)syncPage:(int)page fromDate:(NSDate *)date finishedBlock:(void (^)())finishedBlock {
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
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"%K IN %@", @"userId", [contacts allKeys]];
            
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
            
            for (User *contact in results) {
                // update/delete contact and remove from list
                NSDictionary *contactDict = contacts[contact.userId];
                [contacts removeObjectForKey:contact.userId];
                
                if ([contact.syncStatus intValue] != UserDeleted) {
                    // update contact
                    [contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:contactDict]];
                    contact.contactUpdated = [DateConverter convertToDate:contactDict[@"contact_updated"]];
                    contact.syncStatus = @(UserSynced);
                }
            }
            
            // all left over are new contacts unless they are deleted
            for (NSNumber *contactId in [contacts allKeys]) {
                if (![contacts[contactId][@"is_contact"] boolValue]) continue;
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:objectContext];
                User *contact = [[User alloc] initWithEntity:entity insertIntoManagedObjectContext:objectContext];
                
                [contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:contacts[contactId]]];
                contact.contactUpdated = [DateConverter convertToDate:contacts[contactId][@"contact_updated"]];
                contact.syncStatus = @(UserSynced);
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
            [self syncPage:page + 1 fromDate:date finishedBlock:finishedBlock];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[operation response] statusCode] == 401) {
                    [[HandshakeSession currentSession] invalidate];
                } else {
                    // retry
                    [self syncPage:page fromDate:date finishedBlock:finishedBlock];
                }
            });
        }];
        [[[NSOperationQueue alloc] init] addOperation:operation];
    });
}

+ (void)deleteContact:(User *)user {
    if (![user.isContact boolValue]) return;
    
    user.isContact = @(NO);
    user.contactUpdated = nil;
    user.syncStatus = @(UserDeleted);
    
    for (FeedItem *item in user.feedItems)
        [user.managedObjectContext deleteObject:item];
    
    [self sync];
}

@end
