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
#import "UserServerSync.h"
#import "GroupServerSync.h"

@implementation FeedItemServerSync

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    [self syncPage:1 completionBlock:^{
        if (completionBlock) completionBlock();
    }];
}

+ (void)syncPage:(int)page completionBlock:(void (^)())completionBlock {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t p = 0;
    
    if (!queue) {
        dispatch_once(&p, ^{
            queue = dispatch_queue_create("handshake_feed_item_sync_queue", NULL);
        });
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"page"] = @(page);
    
    [[HandshakeClient client] GET:@"/feed" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseObject = [HandshakeCoreDataStore removeNullsFromDictionary:responseObject];
        
        // cache users and groups
        
        NSMutableArray *users = [[NSMutableArray alloc] init];
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in responseObject[@"feed"]) {
            if (dict[@"user"]) [users addObject:dict[@"user"]];
            if (dict[@"group"]) [groups addObject:dict[@"group"]];
        }
        
        [UserServerSync cacheUsers:users completionBlock:^(NSArray *usersArray) {
            [GroupServerSync cacheGroups:groups completionsBlock:^(NSArray *groupsArray) {
                dispatch_async(queue, ^{
                    NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
                    
                    // load users in current context
                    NSMutableArray *userIds = [[NSMutableArray alloc] init];
                    for (NSDictionary *dict in users)
                        [userIds addObject:dict[@"id"]];
                    
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
                    request.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", userIds];
                    
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
                    
                    // map users to user ids
                    NSMutableDictionary *usersMap = [[NSMutableDictionary alloc] init];
                    for (User *user in results)
                        usersMap[user.userId] = user;
                    
                    // load groups
                    NSMutableArray *groupIds = [[NSMutableArray alloc] init];
                    for (NSDictionary *dict in groups)
                        [groupIds addObject:dict[@"id"]];
                    
                    request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
                    request.predicate = [NSPredicate predicateWithFormat:@"groupId IN %@", groupIds];
                    
                    [objectContext performBlockAndWait:^{
                        results = [objectContext executeFetchRequest:request error:nil];
                    }];
                    
                    if (!results) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completionBlock) completionBlock();
                        });
                        return;
                    }
                    
                    // map groups to group ids
                    NSMutableDictionary *groupsMap = [[NSMutableDictionary alloc] init];
                    for (Group *group in results)
                        groupsMap[group.groupId] = group;
                    
                    // find feed items
                    
                    NSMutableArray *feedIds = [[NSMutableArray alloc] init];
                    for (NSDictionary *dict in responseObject[@"feed"])
                        [feedIds addObject:dict[@"id"]];
                    
                    request = [[NSFetchRequest alloc] initWithEntityName:@"FeedItem"];
                    request.predicate = [NSPredicate predicateWithFormat:@"feedId IN %@", feedIds];
                    
                    [objectContext performBlockAndWait:^{
                        results = [objectContext executeFetchRequest:request error:nil];
                    }];
                    
                    if (!results) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completionBlock) completionBlock();
                        });
                        return;
                    }
                    
                    // map feeds to feed ids
                    NSMutableDictionary *feedMap = [[NSMutableDictionary alloc] init];
                    for (FeedItem *feedItem in results)
                        feedMap[feedItem.feedId] = feedItem;
                    
                    for (NSDictionary *dict in responseObject[@"feed"]) {
                        FeedItem *item = feedMap[dict[@"id"]];
                        
                        if (!item)
                            item = [[FeedItem alloc] initWithEntity:[NSEntityDescription entityForName:@"FeedItem" inManagedObjectContext:objectContext] insertIntoManagedObjectContext:objectContext];
                        
                        [item updateFromDictionary:dict];
                        
                        if (dict[@"user"])
                            item.user = usersMap[dict[@"user"][@"id"]];
                        if (dict[@"group"])
                            item.group = groupsMap[dict[@"group"][@"id"]];
                    }
                    
                    // special case for page 1 (delete all other feed items)
                    if (page == 1) {
                        request = [[NSFetchRequest alloc] initWithEntityName:@"FeedItem"];
                        request.predicate = [NSPredicate predicateWithFormat:@"!(feedId IN %@)", feedIds];
                        
                        [objectContext performBlockAndWait:^{
                            results = [objectContext executeFetchRequest:request error:nil];
                        }];
                        
                        if (!results) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (completionBlock) completionBlock();
                            });
                            return;
                        }
                        
                        for (FeedItem *item in results)
                            [objectContext deleteObject:item];
                    }
                    
                    // save
                    [objectContext performBlockAndWait:^{
                        [objectContext save:nil];
                    }];
                    
                    // check if last page (< 100 items returned)
                    if ([responseObject[@"feed"] count] < 100) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completionBlock) completionBlock();
                        });
                        return;
                    }
                    
                    // load next page
                    [self syncPage:page + 1 completionBlock:completionBlock];
                });
            }];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            [[HandshakeSession currentSession] invalidate];
        }
        if (completionBlock) completionBlock();
    }];
}

@end
