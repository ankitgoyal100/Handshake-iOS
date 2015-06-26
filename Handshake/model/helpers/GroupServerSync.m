//
//  GroupServerSync.m
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "GroupServerSync.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "DateConverter.h"
#import "FeedItem.h"
#import "Card.h"
#import "UserServerSync.h"
#import "GroupMember.h"

@implementation GroupServerSync

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    // get all groups
    [[HandshakeClient client] GET:@"/groups" parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self cacheGroups:responseObject[@"groups"] completionsBlock:^(NSArray *groups) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
                
                // create ids list
                NSMutableArray *groupIds = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in responseObject[@"groups"])
                    [groupIds addObject:dict[@"id"]];
                
                // delete all groups that don't exist on server
                
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
                
                request.predicate = [NSPredicate predicateWithFormat:@"syncStatus == %@ AND !(groupId IN %@)", @(GroupSynced), groupIds];
                
                __block NSArray *results;
                
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
                
                for (Group *group in results)
                    [objectContext deleteObject:group];
                
                // sync current groups with server
                
                request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
                
                request.predicate = [NSPredicate predicateWithFormat:@"syncStatus!=%@", [NSNumber numberWithInt:GroupSynced]];
                
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
                
                for (Group *group in results) {
                    if ([group.syncStatus intValue] == GroupCreated) {
                        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
                        params[@"name"] = group.name;
                        params[@"card_ids"] = @[((Card *)([[HandshakeSession currentSession] account].cards[0])).cardId];
                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"POST" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:@"/groups"] absoluteString] parameters:params error:nil]];
                        operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        operation.responseSerializer = [HandshakeClient client].responseSerializer;
                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            [group updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"group"]]];
                            group.syncStatus = [NSNumber numberWithInt:GroupSynced];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            // do nothing
                        }];
                        [operations addObject:operation];
                    } else if ([group.syncStatus intValue] == GroupUpdated) {
                        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
                        params[@"name"] = group.name;
                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"PUT" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/groups/%d", [group.groupId intValue]]] absoluteString] parameters:params error:nil]];
                        operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        operation.responseSerializer = [HandshakeClient client].responseSerializer;
                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            [group updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"group"]]];
                            group.syncStatus = [NSNumber numberWithInt:GroupSynced];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            // do nothing
                        }];
                        [operations addObject:operation];
                    } else if ([group.syncStatus intValue] == GroupDeleted) {
                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"DELETE" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/groups/%d", [group.groupId intValue]]] absoluteString] parameters:[[HandshakeSession currentSession] credentials] error:nil]];
                        operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        operation.responseSerializer = [HandshakeClient client].responseSerializer;
                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            [objectContext deleteObject:group];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            // do nothing
                        }];
                        [operations addObject:operation];
                    }
                }
                
                NSArray *preparedOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                    // do nothing
                } completionBlock:^(NSArray *operations) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        // save
                        [objectContext performBlockAndWait:^{
                            [objectContext save:nil];
                        }];
                        [[HandshakeCoreDataStore defaultStore] saveMainContext];
                        
                        NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
                        
                        // load group members
                        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
                        
                        [objectContext performBlockAndWait:^{
                            results = [objectContext executeFetchRequest:request error:nil];
                        }];
                        
                        if (results) {
                            for (Group *group in results)
                                [self loadGroupMembers:group completionBlock:nil];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // end sync
                            if (completionBlock) completionBlock();
                        });
                    });
                }];
                [[[NSOperationQueue alloc] init] addOperations:preparedOperations waitUntilFinished:NO];
            });
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[operation response] statusCode] == 401) {
                // invalidate session
                [[HandshakeSession currentSession] invalidate];
            } else // retry
                [self syncWithCompletionBlock:completionBlock];
        });
    }];
}

+ (void)cacheGroups:(NSArray *)jsonArray completionsBlock:(void (^)(NSArray *))completionBlock {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t p = 0;
    
    if (!queue) {
        dispatch_once(&p, ^{
            queue = dispatch_queue_create("handshake_group_sync_queue", NULL);
        });
    }
    
    dispatch_async(queue, ^{
        NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        // get groups from db
        
        NSMutableArray *groupIds = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in jsonArray)
            [groupIds addObject:dict[@"id"]];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
        request.predicate = [NSPredicate predicateWithFormat:@"groupId IN %@", groupIds];
        
        __block NSArray *results;
        
        [objectContext performBlockAndWait:^{
            results = [objectContext executeFetchRequest:request error:nil];
        }];
        
        if (!results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) completionBlock(nil); // error
            });
            return;
        }
        
        // map ids to Group objects
        NSMutableDictionary *groupMap = [[NSMutableDictionary alloc] init];
        for (Group *group in results)
            groupMap[group.groupId] = group;
        
        for (NSDictionary *dict in jsonArray) {
            // update/create groups
            
            Group *group = groupMap[dict[@"id"]];
            
            if (!group) {
                group = [[Group alloc] initWithEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:objectContext] insertIntoManagedObjectContext:objectContext];
                group.syncStatus = @(GroupSynced);
            }
            
            if ([group.syncStatus intValue] == GroupSynced)
                [group updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:dict]];
            
            groupMap[dict[@"id"]] = group;
        }
        
        [objectContext performBlockAndWait:^{
            [objectContext save:nil];
        }];
        
        // get groups in main context
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
            request.predicate = [NSPredicate predicateWithFormat:@"groupId IN %@", groupIds];
            
            __block NSArray *results;
            
            [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
                results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:nil];
            }];
            
            NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
            for (Group *group in results)
                map[group.groupId] = group;
            
            NSMutableArray *orderedResults = [[NSMutableArray alloc] initWithCapacity:[results count]];
            
            for (NSNumber *groupId in groupIds)
                [orderedResults addObject:map[groupId]];
            
            if (completionBlock) completionBlock(orderedResults);
        });
    });
}

+ (void)loadGroupMembers:(Group *)group completionBlock:(void (^)())completionBlock {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t p = 0;
    
    if (!queue) {
        dispatch_once(&p, ^{
            queue = dispatch_queue_create("handshake_group_member_sync_queue", NULL);
        });
    }
    
    NSNumber *groupId = group.groupId;
    
    [[HandshakeClient client] GET:[NSString stringWithFormat:@"/groups/%@/members", groupId] parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UserServerSync cacheUsers:responseObject[@"members"] completionBlock:^(NSArray *users) {
            // create group members
            
            dispatch_async(queue, ^{
                NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
                
                // get group in current context
                
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
                request.predicate = [NSPredicate predicateWithFormat:@"groupId == %@", groupId];
                request.fetchLimit = 1;
                
                __block NSArray *results;
                
                [objectContext performBlockAndWait:^{
                    results = [objectContext executeFetchRequest:request error:nil];
                }];
                
                Group *group = nil;
                
                if (results && [results count] == 1)
                    group = results[0];
                
                if (!group) {
                    // error
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) completionBlock();
                    });
                    return;
                }
                
                // delete all current group members
                
                [group removeMembers:group.members];
                
                // fetch users in current context
                
                NSMutableArray *userIds = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in responseObject[@"members"])
                    [userIds addObject:dict[@"id"]];
                
                request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
                request.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", userIds];
                
                [objectContext performBlockAndWait:^{
                    results = [objectContext executeFetchRequest:request error:nil];
                }];
                
                if (!results) {
                    // error
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) completionBlock();
                    });
                    return;
                }
                
                // create user map
                NSMutableDictionary *usersMap = [[NSMutableDictionary alloc] init];
                for (User *user in results)
                    usersMap[user.userId] = user;
                
                // create group members
                for (NSDictionary *dict in responseObject[@"members"]) {
                    User *user = usersMap[dict[@"id"]];
                    
                    if (!user) continue;
                    
                    GroupMember *member = [[GroupMember alloc] initWithEntity:[NSEntityDescription entityForName:@"GroupMember" inManagedObjectContext:objectContext] insertIntoManagedObjectContext:objectContext];
                    
                    member.user = user;
                    
                    [group addMembersObject:member];
                }
                
                // save
                
                [objectContext performBlockAndWait:^{
                    [objectContext save:nil];
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock();
                });
            });
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401)
            [[HandshakeSession currentSession] invalidate];
        else
            if (completionBlock) completionBlock();
    }];
}

+ (void)deleteGroup:(Group *)group {
    group.syncStatus = @(GroupDeleted);
    for (FeedItem *item in group.feedItems)
        [group.managedObjectContext deleteObject:item];
    
    [self sync];
}

@end
