//
//  FacebookHelper.h
//  Handshake
//
//  Created by Sam Ober on 9/12/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookHelper : NSObject

+ (void)loadFacebookAccountWithSuccessBlock:(void (^)(NSString *username, NSString *name))successBlock errorBlock:(void (^)(NSError *error))errorBlock;

+ (void)nameForUsername:(NSString *)username successBlock:(void (^)(NSString *name))successBlock errorBlock:(void (^)(NSError *error))errorBlock;

+ (NSString *)username;
+ (NSString *)name;

@end
