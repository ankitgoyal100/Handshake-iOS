//
//  HandshakeClient.h
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeUser.h"
#import "HandshakeCard.h"

typedef enum {
    NONE,
    NETWORK_ERROR,
    AUTHENTICATION_ERROR,
    NOT_LOGGED_IN,
    INPUT_ERROR,
    EMAIL_TAKEN
} HandshakeError;

@interface HandshakeAPI : NSObject

+ (HandshakeAPI *)client;

- (BOOL)restoreSession;

- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password success:(void (^)())success failure:(void (^)(HandshakeError))failure;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password success:(void (^)())success failure:(void (^)(HandshakeError, NSArray *))failure;

- (void)updateEmail:(NSString *)email success:(void (^)(NSString *email))success failure:(void (^)(HandshakeError, NSArray *))failure;
- (void)resendConfirmation:(void (^)())success failure:(void (^)(HandshakeError))failure;

- (void)cards:(void (^)(NSArray *))success failure:(void (^)(HandshakeError))failure;

- (void)createCard:(HandshakeCard *)card success:(void (^)(HandshakeCard *))success failure:(void (^)(HandshakeError))failure;
- (void)updateCard:(HandshakeCard *)card success:(void (^)(HandshakeCard *))success failure:(void (^)(HandshakeError))failure;
- (void)deleteCard:(HandshakeCard *)card success:(void (^)())success failure:(void (^)(HandshakeError))failure;

- (void)contactsOnPage:(int)page success:(void (^)(NSArray *))success failure:(void (^)(HandshakeError))failure;

- (void)logout;

@property (nonatomic, strong, readonly) HandshakeUser *currentUser;

@end
