//
//  HandshakeSession.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

#define SESSION_STARTED @"HandshakeSessionCreatedNotification"
#define SESSION_RESTORED @"HandshakeSessionRestoredNotification"
#define SESSION_ENDED @"HandshakeSessionEndedNotification"
#define SESSION_INVALID @"HandshakeSessionInvalidNotification"

typedef enum {
    NETWORK_ERROR,
    AUTHENTICATION_ERROR,
    INVALID_SESSION
} HandshakeSessionError;

typedef void (^LoginSuccessBlock)();
typedef void (^LoginFailedBlock)(HandshakeSessionError error);

@interface HandshakeSession : NSObject

+ (BOOL)restoreSession;
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password successBlock:(LoginSuccessBlock)successBlock failedBlock:(LoginFailedBlock)failedBlock;

+ (User *)user;
+ (NSString *)authToken;

+ (NSDictionary *)credentials;

+ (void)logout;
+ (void)invalidate;

@end
