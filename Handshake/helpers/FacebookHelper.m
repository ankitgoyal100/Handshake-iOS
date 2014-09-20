//
//  FacebookHelper.m
//  Handshake
//
//  Created by Sam Ober on 9/12/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "FacebookHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"

static NSString *username;
static NSString *name;

static NSMutableDictionary *nameCache;

@implementation FacebookHelper

+ (void)loadFacebookAccountWithSuccessBlock:(void (^)(NSString *, NSString *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    if (username) {
        if (successBlock) successBlock(username, name);
        return;
    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            [[AFHTTPRequestOperationManager manager] GET:[@"http://graph.facebook.com/" stringByAppendingString:result[@"id"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                username = responseObject[@"username"];
                name = responseObject[@"name"];
                if (successBlock) successBlock(username, name);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (errorBlock) errorBlock(error);
            }];
        } else {
            if (errorBlock) errorBlock(error);
        }
    }];
}

+ (void)nameForUsername:(NSString *)username successBlock:(void (^)(NSString *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    if (!nameCache) nameCache = [[NSMutableDictionary alloc] init];
    else if (nameCache[username]) {
        successBlock(nameCache[username]);
        return;
    }
    
    [[AFHTTPRequestOperationManager manager] GET:[@"http://graph.facebook.com/" stringByAppendingString:username] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [nameCache setObject:responseObject[@"name"] forKey:username];
        successBlock(nameCache[username]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

+ (NSString *)username {
    return username;
}

+ (NSString *)name {
    return name;
}

@end
