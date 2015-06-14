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
#import "FeedItemServerSync.h"
#import "UserServerSync.h"

@implementation RequestServerSync

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    [[HandshakeClient client] GET:@"/requests" parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UserServerSync cacheUsers:responseObject[@"requests"] completionBlock:^(NSArray *users) {
            // update old requestees
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                // get list of ids
                NSMutableArray *userIds = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in responseObject[@"requests"])
                    [userIds addObject:dict[@"id"]];
                
                NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
                
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
                request.predicate = [NSPredicate predicateWithFormat:@"requestReceived == %@ AND !(userId IN %@)", @(YES), userIds];
                
                __block NSArray *results;
                
                [objectContext performBlockAndWait:^{
                    results = [objectContext executeFetchRequest:request error:nil];
                }];
                
                if (!results) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) completionBlock();
                    });
                    return;
                }
                
                // set requestReceived to NO
                for (User *user in results)
                    user.requestReceived = @(NO);
                
                [objectContext performBlockAndWait:^{
                    [objectContext save:nil];
                }];
                [[HandshakeCoreDataStore defaultStore] saveMainContext];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock();
                });
            });
        }];
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
        
        [FeedItemServerSync sync];
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
