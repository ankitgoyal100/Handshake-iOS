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

@interface FacebookHelper() <UIAlertViewDelegate>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *nameCache;

@property (nonatomic, copy) AccountLoadedBlock loadedBlock;
@property (nonatomic, copy) AccountErrorBlock errorBlock;

@end

@implementation FacebookHelper

+ (FacebookHelper *)sharedHelper {
    static FacebookHelper *sharedHelper = nil;
    if (!sharedHelper) sharedHelper = [[FacebookHelper alloc] init];
    return sharedHelper;
}

- (NSMutableDictionary *)nameCache {
    if (!_nameCache) _nameCache = [[NSMutableDictionary alloc] init];
    return _nameCache;
}

- (void)loginWithSuccessBlock:(AccountLoadedBlock)successBlock errorBlock:(AccountErrorBlock)errorBlock {
    if (FBSession.activeSession.state == FBSessionStateOpen) {
        [self loadFacebookAccountWithSuccessBlock:^(NSString *username, NSString *name) {
            if (successBlock) successBlock(username, name);
        } errorBlock:^(NSError *error) {
            if (errorBlock) errorBlock(error);
        }];
    } else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (!error) {
                [self loadFacebookAccountWithSuccessBlock:^(NSString *username, NSString *name) {
                    if (successBlock) successBlock(username, name);
                } errorBlock:^(NSError *error) {
                    if (errorBlock) errorBlock(error);
                }];
            }
        }];
    } else {
        self.loadedBlock = successBlock;
        self.errorBlock = errorBlock;
        
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (!error) {
                [self loadFacebookAccountWithSuccessBlock:^(NSString *username, NSString *name) {
                    if (self.loadedBlock) self.loadedBlock(username, name);
                } errorBlock:^(NSError *error) {
                    if (self.errorBlock) self.errorBlock(error);
                }];
            }
        }];
    }
}

- (void)loadFacebookAccountWithSuccessBlock:(AccountLoadedBlock)successBlock errorBlock:(AccountErrorBlock)errorBlock {
    if (self.username) {
        if (successBlock) successBlock(self.username, self.name);
        return;
    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            self.username = result[@"id"];
            self.name = result[@"name"];
            successBlock(self.username, self.name);
        } else {
            if (errorBlock) errorBlock(error);
        }
    }];
}

- (void)nameForUsername:(NSString *)username successBlock:(void (^)(NSString *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    if (self.nameCache[username]) {
        if (successBlock) successBlock(self.nameCache[username]);
        return;
    }
    
    [[AFHTTPRequestOperationManager manager] GET:[@"http://graph.facebook.com/" stringByAppendingString:username] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.nameCache setObject:responseObject[@"name"] forKey:username];
        if (successBlock) successBlock(self.nameCache[username]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock(error);
    }];
}

- (void)logout {
    [FBSession.activeSession closeAndClearTokenInformation];
    
    self.name = nil;
    self.username = nil;
}

@end
