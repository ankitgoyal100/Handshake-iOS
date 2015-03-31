//
//  TwitterHelper.h
//  Handshake
//
//  Created by Sam Ober on 9/23/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LoginSuccessBlock)(NSString *username);

typedef enum {
    TwitterStatusNotFollowing = 0,
    TwitterStatusFollowing,
    TwitterStatusRequested
} TwitterStatus;

@interface TwitterHelper : NSObject

+ (TwitterHelper *)sharedHelper;

- (void)loginWithSuccessBlock:(LoginSuccessBlock)successBlock;
- (void)logout;

- (void)follow:(NSString *)username successBlock:(void (^)(int isProtected))successBlock;
- (void)unfollow:(NSString *)username successBlock:(void (^)())successBlock;

- (void)check:(NSString *)username successBlock:(void (^)(TwitterStatus status))successBlock;

@property (nonatomic, strong, readonly) NSString *username;

@end
