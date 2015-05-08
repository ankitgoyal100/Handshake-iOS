//
//  HandshakeSession.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

#define SESSION_STARTED @"HandshakeSessionCreatedNotification"
#define SESSION_RESTORED @"HandshakeSessionRestoredNotification"
#define SESSION_ENDED @"HandshakeSessionEndedNotification"
#define SESSION_INVALID @"HandshakeSessionInvalidNotification"

typedef enum {
    NETWORK_ERROR,
    AUTHENTICATION_ERROR
} HandshakeSessionError;

@class HandshakeSession;

typedef void (^LoginSuccessBlock)(HandshakeSession *session);
typedef void (^LoginFailedBlock)(HandshakeSessionError error);

@interface HandshakeSession : NSObject

@property (nonatomic, strong, readonly) Account *account;
@property (nonatomic, strong, readonly) NSString *authToken;
@property (nonatomic, strong, readonly) NSDictionary *credentials;

+ (HandshakeSession *)currentSession;
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password successBlock:(LoginSuccessBlock)successBlock failedBlock:(LoginFailedBlock)failedBlock;

- (void)logout;
- (void)invalidate;

@end
