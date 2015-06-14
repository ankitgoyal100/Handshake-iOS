//
//  UserServerSync.m
//  Handshake
//
//  Created by Sam Ober on 6/14/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "UserServerSync.h"
#import "HandshakeCoreDataStore.h"
#import "User.h"

@implementation UserServerSync

+ (void)cacheUsers:(NSArray *)jsonArray completionBlock:(void (^)(NSArray *users))completionBlock {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t p = 0;
    
    if (!queue) {
        dispatch_once(&p, ^{
            queue = dispatch_queue_create("handshake_user_sync_queue", NULL);
        });
    }
    
    dispatch_async(queue, ^{
        NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        // get users from db
        
        NSMutableArray *userIds = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in jsonArray)
            [userIds addObject:dict[@"id"]];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", userIds];
        
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
        
        // map ids to User objects
        NSMutableDictionary *userMap = [[NSMutableDictionary alloc] init];
        for (User *user in results)
            userMap[user.userId] = user;
        
        // recreate id list
        [userIds removeAllObjects];
        
        for (NSDictionary *dict in jsonArray) {
            // update/create users
            
            User *user = userMap[dict[@"id"]];
            
            if (!user) {
                user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:objectContext] insertIntoManagedObjectContext:objectContext];
                user.syncStatus = @(UserSynced);
            }
            
            if ([user.syncStatus intValue] == UserSynced)
                [user updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:dict]];
            
            [userIds addObject:user.userId];
        }
        
        [objectContext performBlockAndWait:^{
            [objectContext save:nil];
        }];
        
        // get users in main context
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
            request.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", userIds];
            
            __block NSArray *results;
            
            [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
                results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:nil];
            }];
            
            NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
            for (User *user in results)
                map[user.userId] = user;
            
            NSMutableArray *orderedResults = [[NSMutableArray alloc] initWithCapacity:[results count]];
            
            for (NSNumber *userId in userIds)
                [orderedResults addObject:map[userId]];
            
            if (completionBlock) completionBlock(orderedResults);
        });
    });
}

@end
