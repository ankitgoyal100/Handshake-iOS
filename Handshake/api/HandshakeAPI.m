//
//  HandshakeClient.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeAPI.h"
#import "AFHTTPRequestOperationManager.h"
#import "HandshakeCard.h"
#import "FacebookHelper.h"
#import "HandshakeContact.h"
#import "SSKeychain.h"
#import "Handshake.h"

@interface HandshakeAPI()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, strong) HandshakeUser *currentUser;
@property (nonatomic, strong) NSString *authToken;

@end

@implementation HandshakeAPI

- (AFHTTPRequestOperationManager *)manager {
    if (!_manager) {
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost:3000/"]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _manager;
}

+ (HandshakeAPI *)client {
    static HandshakeAPI *client = nil;
    if (client == nil) {
        client = [[HandshakeAPI alloc] init];
    }
    return client;
}

- (BOOL)restoreSession {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:@"current_user_email"];
    
    if (email) {
        self.authToken = [SSKeychain passwordForService:@"Handshake" account:email];
        self.currentUser = [[HandshakeUser alloc] init];
        self.currentUser.email = email;
        
        if (!self.authToken) return NO;
        
        [[self manager] GET:@"/account" parameters:@{ @"auth_token":self.authToken, @"user_email":email } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.currentUser = [HandshakeUser userFromDictionary:responseObject[@"user"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGGED_IN_NOTIFICATION object:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[operation response] statusCode] == 401)
                [self forceLogout];
            else
                [self restoreSession];
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password success:(void (^)())success failure:(void (^)(HandshakeError))failure {
    [self.manager POST:@"/tokens" parameters:@{ @"email":email, @"password":password } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.authToken = responseObject[@"auth_token"];
        self.currentUser = [HandshakeUser userFromDictionary:responseObject[@"user"]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.currentUser.email forKey:@"current_user_email"];
        [defaults synchronize];
        
        [SSKeychain setPassword:self.authToken forService:@"Handshake" account:self.currentUser.email];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGGED_IN_NOTIFICATION object:nil];
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401)
            failure(AUTHENTICATION_ERROR);
        else
            failure(NETWORK_ERROR);
    }];
}

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password success:(void (^)())success failure:(void (^)(HandshakeError, NSArray *))failure {
    [self.manager POST:@"/account" parameters:@{ @"email":email, @"password":password } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[HandshakeAPI client] authenticateWithEmail:email password:password success:^{
            success();
        } failure:^(HandshakeError error) {
            failure(error, nil);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 422) {
            failure(INPUT_ERROR, [[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil] objectForKey:@"errors"]);
        } else
            failure(NETWORK_ERROR, nil);
    }];
}

- (void)updateEmail:(NSString *)email success:(void (^)(NSString *))success failure:(void (^)(HandshakeError, NSArray *))failure {
    if (!self.currentUser) {
        [self forceLogout];
        failure(NOT_LOGGED_IN, nil);
        return;
    }
    
    [self.manager PUT:@"/account" parameters:@{ @"auth_token":self.authToken, @"user_email":self.currentUser.email, @"email":email } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.currentUser = [HandshakeUser userFromDictionary:responseObject[@"user"]];
        success(self.currentUser.unconfirmedEmail);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            [self forceLogout];
            failure(NOT_LOGGED_IN, nil);
        } else if ([[operation response] statusCode] == 422) {
            failure(INPUT_ERROR, [[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil] objectForKey:@"errors"]);
        } else
            failure(NETWORK_ERROR, nil);
    }];
}

- (void)resendConfirmation:(void (^)())success failure:(void (^)(HandshakeError))failure {
    if (!self.currentUser) {
        [self forceLogout];
        failure(NOT_LOGGED_IN);
        return;
    }
    
    [self.manager POST:@"/confirmation" parameters:@{ @"user":@{ @"email":self.currentUser.email } } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            [self forceLogout];
            failure(NOT_LOGGED_IN);
        } else
            failure(NETWORK_ERROR);
    }];
}

- (void)cards:(void (^)(NSArray *))success failure:(void (^)(HandshakeError))failure {
    if (!self.currentUser) {
        [self forceLogout];
        failure(NOT_LOGGED_IN);
        return;
    }
    
    [self.manager GET:@"/cards" parameters:@{ @"auth_token":self.authToken, @"user_email":self.currentUser.email } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *cards = [[NSMutableArray alloc] init];
        for (NSDictionary *cardDictionary in responseObject[@"cards"]) {
            HandshakeCard *card = [HandshakeCard cardFromDictionary:cardDictionary];
            [cards addObject:card];
        }
        success(cards);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            [self forceLogout];
            failure(NOT_LOGGED_IN);
        } else
            failure(NETWORK_ERROR);
    }];
}

- (void)createCard:(HandshakeCard *)card success:(void (^)(HandshakeCard *))success failure:(void (^)(HandshakeError))failure {
    if (!self.currentUser) {
        [self forceLogout];
        failure(NOT_LOGGED_IN);
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{ @"auth_token":self.authToken, @"user_email":self.currentUser.email }];
    [params addEntriesFromDictionary:[HandshakeCard dictionaryFromCard:card]];
    
    [self.manager POST:@"/cards" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success([HandshakeCard cardFromDictionary:responseObject[@"card"]]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            [self forceLogout];
            failure(NOT_LOGGED_IN);
        } else
            failure(NETWORK_ERROR);
    }];
}

- (void)updateCard:(HandshakeCard *)card success:(void (^)(HandshakeCard *))success failure:(void (^)(HandshakeError))failure {
    if (!self.currentUser) {
        [self forceLogout];
        failure(NOT_LOGGED_IN);
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{ @"auth_token":self.authToken, @"user_email":self.currentUser.email }];
    [params addEntriesFromDictionary:[HandshakeCard dictionaryFromCard:card]];
    
    [self.manager PUT:[@"/cards/" stringByAppendingString:[[NSNumber numberWithLong:card.cardId] stringValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success([HandshakeCard cardFromDictionary:responseObject[@"card"]]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            [self forceLogout];
            failure(NOT_LOGGED_IN);
        } else
            failure(NETWORK_ERROR);
    }];
}

- (void)deleteCard:(HandshakeCard *)card success:(void (^)())success failure:(void (^)(HandshakeError))failure {
    if (!self.currentUser) {
        [self forceLogout];
        failure(NOT_LOGGED_IN);
        return;
    }
    
    [self.manager DELETE:[@"/cards/" stringByAppendingString:[[NSNumber numberWithLong:card.cardId] stringValue]] parameters:@{ @"auth_token":self.authToken, @"user_email":self.currentUser.email } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            [self forceLogout];
            failure(NOT_LOGGED_IN);
        } else
            failure(NETWORK_ERROR);
    }];
}

- (void)contactsOnPage:(int)page success:(void (^)(NSArray *))success failure:(void (^)(HandshakeError))failure {
    if (!self.currentUser) {
        [self forceLogout];
        failure(NOT_LOGGED_IN);
        return;
    }
    
    [self.manager GET:@"/contacts" parameters:@{ @"auth_token":self.authToken, @"user_email":self.currentUser.email, @"page":[NSNumber numberWithInteger:page] } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        for (NSDictionary *contact in responseObject[@"contacts"]) {
            [contacts addObject:[HandshakeContact contactFromDictionary:contact]];
        }
        success(contacts);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401) {
            [self forceLogout];
            failure(NOT_LOGGED_IN);
        } else
            failure(NETWORK_ERROR);
    }];
}

- (void)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"current_user_email"];
    [defaults synchronize];
    
    if (self.currentUser) [SSKeychain deletePasswordForService:@"Handshake" account:self.currentUser.email];
    
    self.authToken = nil;
    self.currentUser = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_NOTIFICATION object:nil];
}

- (void)forceLogout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"current_user_email"];
    [defaults synchronize];
    
    if (self.currentUser) [SSKeychain deletePasswordForService:@"Handshake" account:self.currentUser.email];
    
    self.authToken = nil;
    self.currentUser = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FORCE_LOGOUT_NOTIFICATION object:nil];
}

@end
