//
//  FeedItemServerSync.m
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "FeedItemServerSync.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"

@implementation FeedItemServerSync

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
