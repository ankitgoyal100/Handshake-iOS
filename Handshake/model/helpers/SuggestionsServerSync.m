//
//  SuggestionsServerSync.m
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "SuggestionsServerSync.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "UserServerSync.h"
#import "User.h"
#import "Suggestion.h"

@implementation SuggestionsServerSync

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t p = 0;
    
    if (!queue) {
        dispatch_once(&p, ^{
            queue = dispatch_queue_create("handshake_suggestion_sync_queue", NULL);
        });
    }
    
    [[HandshakeClient client] GET:@"/suggestions" parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UserServerSync cacheUsers:responseObject[@"suggestions"] completionBlock:^(NSArray *users) {
            
            dispatch_async(queue, ^{
                // get users in background context
                
                NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
                
                NSMutableArray *userIds = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in responseObject[@"suggestions"])
                    [userIds addObject:dict[@"id"]];
                
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
                request.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", userIds];
                
                __block NSArray *results;
                
                [objectContext performBlockAndWait:^{
                    results = [objectContext executeFetchRequest:request error:nil];
                }];
                
                if (!results) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) completionBlock(); //sync failed
                    });
                    return;
                }
                
                for (User *user in results) {
                    if (user.suggestion) continue; // suggestion already created
                    
                    Suggestion *suggestion = [[Suggestion alloc] initWithEntity:[NSEntityDescription entityForName:@"Suggestion" inManagedObjectContext:objectContext] insertIntoManagedObjectContext:objectContext];
                    suggestion.user = user;
                }
                
                // delete all old suggestions
                
                request = [[NSFetchRequest alloc] initWithEntityName:@"Suggestion"];
                request.predicate = [NSPredicate predicateWithFormat:@"!(user.userId IN %@)", userIds];
                
                [objectContext performBlockAndWait:^{
                    results = [objectContext executeFetchRequest:request error:nil];
                }];
                
                if (!results) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) completionBlock(); //sync failed
                    });
                    return;
                }
                
                for (Suggestion *s in results)
                    [objectContext deleteObject:s];
                
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
        if ([[operation response] statusCode] == 401)
            [[HandshakeSession currentSession] invalidate];
        if (completionBlock) completionBlock();
    }];
}

@end
