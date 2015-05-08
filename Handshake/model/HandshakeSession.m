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
#import "Card.h"
#import "Contact.h"
#import "Group.h"

static HandshakeSession *session = nil;

@interface HandshakeSession()

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) NSDictionary *credentials;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HandshakeSession

+ (void)initSession {
    session = [[HandshakeSession alloc] init];
    session.managedObjectContext = [[HandshakeCoreDataStore defaultStore] mainManagedObjectContext];
}

+ (void)destroySession {
    if (!session) return;
    
    if (session.account) {
        [SSKeychain deletePasswordForService:@"Handshake" account:session.account.email];
        [session.managedObjectContext performBlockAndWait:^{
            NSError *error;
            [session.managedObjectContext deleteObject:session.account];
            [session.managedObjectContext save:&error];
        }];
    }
    
    session = nil;
}

// returns the current session
+ (HandshakeSession *)currentSession {
    if (!session) {
        // see if we can restore the session
        
        // search in Core Data for User
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Account"];
        request.fetchLimit = 1;
        
        __block NSArray *results;
        
        [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
            NSError *error;
            results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:&error];
        }];
        
        if ([results count]) {
            [self initSession];
            session.account = results[0];
            session.authToken = [SSKeychain passwordForService:@"Handshake" account:session.account.email];
            
            if (!session.authToken) {
                [self destroySession];
                return nil;
            }
            
            session.credentials = @{ @"auth_token":session.authToken, @"user_id":session.account.userId };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_RESTORED object:nil];
            
            [Account sync];
            [Card sync];
            [Contact sync];
            [Group sync];
            
            return session;
        }
        
        return nil;
    } else {
        return session;
    }
}

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password successBlock:(LoginSuccessBlock)successBlock failedBlock:(LoginFailedBlock)failedBlock {
    
    // destroy existing session
    [self destroySession];
    
    [[HandshakeClient client] POST:@"/tokens" parameters:@{ @"email":email, @"password":password } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self initSession];
        session.authToken = responseObject[@"auth_token"];
        
        // make sure no other accounts exist
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Account"];
        
        __block NSArray *results;
        
        [session.managedObjectContext performBlockAndWait:^{
            NSError *error;
            results = [session.managedObjectContext executeFetchRequest:request error:&error];
        }];
        
        if (results) {
            for (Account *account in results) {
                [session.managedObjectContext deleteObject:account];
            }
        }
        
        // create new account
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:session.managedObjectContext];
        session.account = [[Account alloc] initWithEntity:entity insertIntoManagedObjectContext:session.managedObjectContext];
        
        [session.account updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
        
        [SSKeychain setPassword:session.authToken forService:@"Handshake" account:session.account.email];
        
        session.credentials = @{ @"auth_token":session.authToken, @"user_id":session.account.userId };
        
        if (successBlock) successBlock(session);
        
        [session.managedObjectContext performBlockAndWait:^{
            NSError *error;
            [session.managedObjectContext save:&error];
        }];
        
        [Account sync];
        [Card sync];
        [Contact sync];
        [Group sync];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            if (failedBlock) failedBlock(AUTHENTICATION_ERROR);
        } else if (failedBlock) failedBlock(NETWORK_ERROR);
    }];
}

- (void)logout {
    [HandshakeSession destroySession];
    [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_ENDED object:nil];
}

- (void)invalidate {
    [HandshakeSession destroySession];
    [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_INVALID object:nil];
    
//    [[HandshakeClient client] GET:@"/account" parameters:self.credentials success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        // nothing wrong
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil];
//        if ([[operation response] statusCode] == 401 && [dictionary[@"error"] containsString:@"confirm"]) {
//            // confirmation error
//            NSString *email = [self user].email;
//            [[HandshakeClient client] POST:@"/confirmation" parameters:@{ @"user":@{ @"email":email } } success:nil failure:nil];
//            [self destroySession];
//            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_INVALID object:@{ @"confirmation_error":@YES, @"email":email }];
//        } else {
//            [self destroySession];
//            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_INVALID object:@{ @"confirmation_error":@NO }];
//        }
//    }];
}

@end
