//
//  Group.m
//  Handshake
//
//  Created by Sam Ober on 5/3/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "Group.h"
#import "GroupMember.h"
#import "Card.h"
#import "DateConverter.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "AFNetworking.h"
#import "HandshakeClient.h"

static BOOL syncing = NO;

@implementation Group

@dynamic code;
@dynamic createdAt;
@dynamic groupId;
@dynamic name;
@dynamic updatedAt;
@dynamic syncStatus;
@dynamic members;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.groupId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.name = dictionary[@"name"];
    self.code = dictionary[@"code"];
    
    [self removeMembers:self.members];
    
    for (NSDictionary *memberDict in dictionary[@"members"]) {
        GroupMember *member = [[GroupMember alloc] initWithEntity:[NSEntityDescription entityForName:@"GroupMember" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        [member updateFromDictionary:memberDict];
        [self addMembersObject:member];
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
        
        // get all groups
        [[HandshakeClient client] GET:@"/groups" parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // map groups to ids
            NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
            for (NSDictionary *groupDict in responseObject[@"groups"]) {
                groups[groupDict[@"id"]] = groupDict;
            }
            
            // get local groups
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
            
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
            
            // update/delete records
            for (Group *group in results) {
                // if group is new skip
                if ([group.syncStatus intValue] == GroupCreated) continue;
                
                NSDictionary *groupDict = groups[group.groupId];
                
                if (!groupDict) {
                    // record doesn't exist on server - delete group
                    [objectContext deleteObject:group];
                } else {
                    // update if group is newer
                    if ([[DateConverter convertToDate:groupDict[@"updated_at"]] timeIntervalSinceDate:group.updatedAt] > 0) {
                        [group updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:groupDict]];
                        group.syncStatus = [NSNumber numberWithInt:GroupSynced];
                    }
                }
                
                [groups removeObjectForKey:group.groupId];
            }
            
            // any remaining groups are new
            for (NSNumber *groupId in [groups allKeys]) {
                NSDictionary *groupDict = groups[groupId];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:objectContext];
                Group *group = [[Group alloc] initWithEntity:entity insertIntoManagedObjectContext:objectContext];
                
                [group updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:groupDict]];
                group.syncStatus = [NSNumber numberWithInt:GroupSynced];
            }
            
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
                    syncing = NO;
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
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
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
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
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
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
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
                    });
                });
            }];
            [[[NSOperationQueue alloc] init] addOperations:preparedOperations waitUntilFinished:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[operation response] statusCode] == 401) {
                    // invalidate session
                    syncing = NO;
                    [[HandshakeSession currentSession] invalidate];
                } else // retry
                    [self syncWithCompletionBlock:completionBlock];
            });
        }];
    });
}

@end
