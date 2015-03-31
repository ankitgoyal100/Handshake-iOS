//
//  HandshakeSession.m
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeSession.h"
#import "AFNetworking.h"
#import <CoreData/CoreData.h>
#import "HandshakeCoreDataStore.h"
#import "SSKeychain.h"
#import "HandshakeClient.h"

@interface HandshakeSession()

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) User *user;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HandshakeSession

+ (HandshakeSession *)session {
    static HandshakeSession *session = nil;
    if (!session) {
        session = [[HandshakeSession alloc] init];
        session.managedObjectContext = [[HandshakeCoreDataStore defaultStore] mainManagedObjectContext];
    }
    return session;
}

+ (BOOL)restoreSession {
    // search in Core Data for User
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.fetchLimit = 1;
    
    __block NSArray *results;
    HandshakeSession *session = [self session];
    
    [session.managedObjectContext performBlockAndWait:^{
        NSError *error;
        results = [session.managedObjectContext executeFetchRequest:request error:&error];
    }];
    
    if ([results count]) {
        session.user = results[0];
        session.authToken = [SSKeychain passwordForService:@"Handshake" account:session.user.email];
        
        if (!session.authToken) return NO;
        
        // check if session is valid and update user
        [[HandshakeClient client] GET:@"/account" parameters:@{ @"auth_token":session.authToken, @"user_id":session.user.userId } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [session.user updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_RESTORED object:nil];
            [session.managedObjectContext performBlockAndWait:^{
                NSError *error;
                [session.managedObjectContext save:&error];
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[operation response] statusCode] == 401)
                [HandshakeSession invalidate];
        }];
        
        return YES;
    }
    
    return NO;
}

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password successBlock:(LoginSuccessBlock)successBlock failedBlock:(LoginFailedBlock)failedBlock {
    // check if session already exists
    if ([self session].authToken) [self destroySession];
    
    [[HandshakeClient client] POST:@"/tokens" parameters:@{ @"email":email, @"password":password } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        HandshakeSession *session = [self session];
        session.authToken = responseObject[@"auth_token"];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:session.managedObjectContext];
        session.user = [[User alloc] initWithEntity:entity insertIntoManagedObjectContext:session.managedObjectContext];
        
        [session.user updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
        
        [SSKeychain setPassword:session.authToken forService:@"Handshake" account:session.user.email];
        
        if (successBlock) successBlock();
        
        [session.managedObjectContext performBlockAndWait:^{
            NSError *error;
            [session.managedObjectContext save:&error];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if ([[operation response] statusCode] == 401) {
            if (failedBlock) failedBlock(AUTHENTICATION_ERROR);
        } else if (failedBlock) failedBlock(NETWORK_ERROR);
    }];
}

+ (User *)user {
    return [self session].user;
}

+ (NSString *)authToken {
    return [self session].authToken;
}

+ (NSDictionary *)credentials {
    return @{ @"auth_token":[self authToken], @"user_id":[self user].userId };
}

+ (void)destroySession {
    HandshakeSession *session = [self session];
    
    if (session.user) {
        [SSKeychain deletePasswordForService:@"Handshake" account:session.user.email];
        [session.managedObjectContext performBlockAndWait:^{
            NSError *error;
            [session.managedObjectContext deleteObject:session.user];
            [session.managedObjectContext save:&error];
        }];
    }
    
    session.user = nil;
    session.authToken = nil;
}

+ (void)logout {
    [self destroySession];
    [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_ENDED object:nil];
}

+ (void)invalidate {
    [[HandshakeClient client] GET:@"/account" parameters:[self credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // nothing wrong
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil];
        if ([[operation response] statusCode] == 401 && [dictionary[@"error"] containsString:@"confirm"]) {
            // confirmation error
            NSString *email = [self user].email;
            [[HandshakeClient client] POST:@"/confirmation" parameters:@{ @"user":@{ @"email":email } } success:nil failure:nil];
            [self destroySession];
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_INVALID object:@{ @"confirmation_error":@YES, @"email":email }];
        } else {
            [self destroySession];
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_INVALID object:@{ @"confirmation_error":@NO }];
        }
    }];
}

@end
