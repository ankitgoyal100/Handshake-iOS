//
//  Account.m
//  Handshake
//
//  Created by Sam Ober on 4/1/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "Account.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "HandshakeCoreDataStore.h"
#import "DateConverter.h"

static BOOL syncing = NO;

@implementation Account

@dynamic email;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.userId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.email = dictionary[@"email"];
    self.firstName = dictionary[@"first_name"];
    self.lastName = dictionary[@"last_name"];
    // if no picture or picture is different - update
    if (!dictionary[@"picture"] || (dictionary[@"picture"] && !self.picture)) {
        self.picture = dictionary[@"picture"];
        self.pictureData = nil;
    }
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"email"] = self.email;
    if (self.firstName)
        dict[@"first_name"] = self.firstName;
    if (self.lastName)
        dict[@"last_name"] = self.lastName;
    return dict;
}

+ (void)sync {
    [self syncWithSuccessBlock:nil];
}

+ (void)syncWithSuccessBlock:(void (^)())successBlock {
    if (syncing)
        return;
    
    syncing = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // get account
        
        Account *account = [[HandshakeSession currentSession] account];
        
        if (!account) {
            // no current account found - stop sync
            dispatch_async(dispatch_get_main_queue(), ^{
                syncing = NO;
                if (successBlock) successBlock();
            });
            return;
        }
        
        // get account in background context
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Account"];
        request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", account.userId];
        request.fetchLimit = 1;
        
        __block NSArray *results = nil;
        
        __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        [objectContext performBlockAndWait:^{
            NSError *error;
            results = [objectContext executeFetchRequest:request error:&error];
        }];
        
        if (![results count]) {
            // no current account found - stop sync
            dispatch_async(dispatch_get_main_queue(), ^{
                syncing = NO;
                if (successBlock) successBlock();
            });
            return;
        }
        
        account = results[0];
        
        // get current account
        [[HandshakeClient client] GET:@"/account" parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // check if account has been updated
            if ([account.syncStatus intValue] == AccountUpdated) {
                // attempt to update account
                
                NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
                [params addEntriesFromDictionary:[account dictionary]];
                AFHTTPRequestOperation *operation;
                
                // see if account needs to upload picture
                if (!account.picture && account.pictureData) {
                    operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:@"/account"] absoluteString] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        [formData appendPartWithFileData:account.pictureData name:@"picture" fileName:@"picture.jpg" mimeType:@"image/jpg"];
                    } error:nil]];
                } else {
                    operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"PUT" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:@"/account"] absoluteString] parameters:params error:nil]];
                }
                
                operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                operation.responseSerializer = [HandshakeClient client].responseSerializer;
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [account updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
                    account.syncStatus = [NSNumber numberWithInt:AccountSynced];
                    
                    // save
                    [objectContext performBlockAndWait:^{
                        [objectContext save:nil];
                    }];
                    [[HandshakeCoreDataStore defaultStore] saveMainContext];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        syncing = NO;
                        if (successBlock) successBlock();
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        syncing = NO;
                        if ([[operation response] statusCode] == 401) {
                            [[HandshakeSession currentSession] invalidate];
                        } else if ([[operation response] statusCode] != 422) {
                            // retry the sync
                            [self syncWithSuccessBlock:successBlock];
                        }
                    });
                }];
                [operation start];
            } else {
                [account updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
                account.syncStatus = [NSNumber numberWithInt:AccountSynced];
                
                // save
                [objectContext performBlockAndWait:^{
                    [objectContext save:nil];
                }];
                [[HandshakeCoreDataStore defaultStore] saveMainContext];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    syncing = NO;
                    if (successBlock) successBlock();
                });
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                syncing = NO;
                if ([[operation response] statusCode] == 401) {
                    [[HandshakeSession currentSession] invalidate];
                } else if ([[operation response] statusCode] != 422) {
                    [self syncWithSuccessBlock:successBlock];
                }
            });
        }];
    });
}

@end
