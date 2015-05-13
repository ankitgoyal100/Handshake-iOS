//
//  Request.m
//  Handshake
//
//  Created by Sam Ober on 5/10/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "Request.h"
#import "User.h"
#import "DateConverter.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "Card.h"

static BOOL syncing = NO;

@implementation Request

@dynamic requestId;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic mutual;
@dynamic user;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.requestId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.mutual = dictionary[@"mutual"];
    
    // create/find user
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", dictionary[@"user"][@"id"]];
    request.fetchLimit = 1;
    
    __block NSArray *results;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error;
        results = [self.managedObjectContext executeFetchRequest:request error:&error];
    }];
    
    if (results && [results count] == 1) {
        self.user = results[0];
    } else {
        User *user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        [user updateFromDictionary:dictionary[@"user"]];
        self.user = user;
    }
}

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    if (syncing)
        return;
    
    syncing = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // delete all old requests
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Request"];
        
        __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        __block NSArray *results;
        
        [objectContext performBlockAndWait:^{
            NSError *error;
            results = [objectContext executeFetchRequest:request error:&error];
        }];
        
        if (!results) {
            // sync fucked up - end
            dispatch_async(dispatch_get_main_queue(), ^{
                syncing = NO;
                if (completionBlock) completionBlock();
            });
        }
        
        for (Request *request in results)
            [objectContext deleteObject:request];
        
        // get new requests
        
        [[HandshakeClient client] GET:@"/requests" parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            for (NSDictionary *requestDict in responseObject[@"requests"]) {
                Request *request = [[Request alloc] initWithEntity:[NSEntityDescription entityForName:@"Request" inManagedObjectContext:objectContext] insertIntoManagedObjectContext:objectContext];
                [request updateFromDictionary:requestDict];
            }
            
            // save
            [objectContext performBlockAndWait:^{
                [objectContext save:nil];
            }];
            [[HandshakeCoreDataStore defaultStore] saveMainContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                syncing = NO;
                if (completionBlock) completionBlock();
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[operation response] statusCode] == 401) {
                // invalidate session
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HandshakeSession currentSession] invalidate];
                });
            } else {
                // sync failed
                dispatch_async(dispatch_get_main_queue(), ^{
                    syncing = NO;
                    if (completionBlock) completionBlock();
                });
            }
        }];
    });
}

- (void)acceptWithSuccessBlock:(void (^)(Contact *))successBlock failedBlock:(void (^)())failedBlock {
    if (self.user.userId == [[HandshakeSession currentSession] account].userId) return; // can't accept own request
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"card_ids"] = @[((Card *)[[HandshakeSession currentSession] account].cards[0]).cardId];
    [[HandshakeClient client] POST:[NSString stringWithFormat:@"/requests/%d", [self.requestId intValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // find/create contact
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"contactId == %@", responseObject[@"contact"][@"id"]];
        request.fetchLimit = 1;
        
        __block NSArray *results;
        
        [self.managedObjectContext performBlockAndWait:^{
            NSError *error;
            results = [self.managedObjectContext executeFetchRequest:request error:&error];
        }];
        
        Contact *contact;
        
        if (results && [results count] == 1) {
            contact = results[0];
        } else {
            contact = [[Contact alloc] initWithEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        }
        
        [contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"contact"]]];
        contact.syncStatus = [NSNumber numberWithInt:ContactSynced];
        
        [self.managedObjectContext deleteObject:self];
        
        if (successBlock) successBlock(contact);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401)
            [[HandshakeSession currentSession] invalidate];
        else
            if (failedBlock) failedBlock();
    }];
}

- (void)deleteWithSuccessBlock:(void (^)())successBlock failedBlock:(void (^)())failedBlock {
    [[HandshakeClient client] DELETE:[NSString stringWithFormat:@"/requests/%d", [self.requestId intValue]] parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.managedObjectContext deleteObject:self];
        
        if (successBlock) successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401)
            [[HandshakeSession currentSession] invalidate];
        else
            if (failedBlock) failedBlock();
    }];
}

@end
