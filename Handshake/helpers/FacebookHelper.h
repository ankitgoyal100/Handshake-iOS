//
//  FacebookHelper.h
//  Handshake
//
//  Created by Sam Ober on 9/12/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AccountLoadedBlock)(NSString *username, NSString *name);
typedef void (^AccountErrorBlock)(NSError *error);

@interface FacebookHelper : NSObject

+ (FacebookHelper *)sharedHelper;

- (void)loginWithSuccessBlock:(AccountLoadedBlock)successBlock errorBlock:(AccountErrorBlock)errorBlock;

- (void)loadFacebookAccountWithSuccessBlock:(AccountLoadedBlock)successBlock errorBlock:(AccountErrorBlock)errorBlock;

- (void)nameForUsername:(NSString *)username successBlock:(void (^)(NSString *name))successBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)logout;

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *name;

@end
