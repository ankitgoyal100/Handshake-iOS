//
//  RequestSync.m
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "RequestServerSync.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "Card.h"

@implementation RequestServerSync

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // delete all old requestees
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"requestReceived == %@", @(YES)];
        
        __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        __block NSArray *results;
        
        [objectContext performBlockAndWait:^{
            NSError *error;
            results = [objectContext executeFetchRequest:request error:&error];
        }];
        
        if (!results) {
            // sync fucked up - end
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) completionBlock();
            });
        }
        
        for (User *user in results)
            [objectContext deleteObject:user];
        
        // get new requests
        
        [[HandshakeClient client] GET:@"/requests" parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            for (NSDictionary *userDict in responseObject[@"requests"]) {
                User *user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:objectContext] insertIntoManagedObjectContext:objectContext];
                [user updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:userDict]];
            }
            
            // save
            [objectContext performBlockAndWait:^{
                [objectContext save:nil];
            }];
            [[HandshakeCoreDataStore defaultStore] saveMainContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
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
                    if (completionBlock) completionBlock();
                });
            }
        }];
    });
}

+ (void)sendRequest:(User *)user successBlock:(void (^)(User *))successBlock failedBlock:(void (^)())failedBlock {
    if ([user.requestSent boolValue]) return;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"card_ids"] = @[((Card *)[[HandshakeSession currentSession] account].cards[0]).cardId];
    [[HandshakeClient client] POST:[NSString stringWithFormat:@"/users/%@/request", user.userId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [user updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
        if (successBlock) successBlock(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        user.requestSent = @(NO);
        if (failedBlock) failedBlock();
    }];
    
    user.requestSent = @(YES);
}

+ (void)deleteRequest:(User *)user successBlock:(void (^)(User *))successBlock failedBlock:(void (^)())failedBlock {
    if (![user.requestSent boolValue]) return;
    
    [[HandshakeClient client] DELETE:[NSString stringWithFormat:@"/users/%@/request", user.userId] parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [user updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
        if (successBlock) successBlock(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        user.requestSent = @(YES);
        if (failedBlock) failedBlock();
    }];
    
    user.requestSent = @(NO);
}

+ (void)acceptRequest:(User *)user successBlock:(void (^)(User *))successBlock failedBlock:(void (^)())failedBlock {
    if (![user.requestReceived boolValue]) return;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"card_ids"] = @[((Card *)[[HandshakeSession currentSession] account].cards[0]).cardId];
    [[HandshakeClient client] POST:[NSString stringWithFormat:@"/users/%@/accept", user.userId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [user updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
        if (successBlock) successBlock(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        user.isContact = @(NO);
        user.requestReceived = @(YES);
        if (failedBlock) failedBlock();
    }];
    
    user.isContact = @(YES);
    user.requestReceived = @(NO);
}

+ (void)declineRequest:(User *)user successBlock:(void (^)(User *))successBlock failedBlock:(void (^)())failedBlock {
    if (![user.requestReceived boolValue]) return;
    
    [[HandshakeClient client] DELETE:[NSString stringWithFormat:@"/users/%@/decline", user.userId] parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [user updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
        if (successBlock) successBlock(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        user.requestReceived = @(YES);
    }];
    
    user.requestReceived = @(NO);
}

@end
