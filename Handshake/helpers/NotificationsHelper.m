//
//  NotificationsHelper.m
//  Handshake
//
//  Created by Sam Ober on 6/17/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "NotificationsHelper.h"
#import "UserServerSync.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "FeedItemServerSync.h"
#import "ContactSync.h"

@implementation NotificationsHelper

+ (NotificationsHelper *)sharedHelper {
    static NotificationsHelper *helper = nil;
    static dispatch_once_t p = 0;
    if (!helper) {
        dispatch_once(&p, ^{
            helper = [[NotificationsHelper alloc] init];
        });
    }
    return helper;
}

- (void)registerDevice:(NSString *)token {
    // make sure logged in
    if (![HandshakeSession currentSession]) return;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"token"] = token;
    params[@"platform"] = @"iphone";
    [[HandshakeClient client] POST:@"/devices" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // do nothing
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // do nothing
    }];
}

- (void)syncSettings {
    // make sure logged in
    if (![HandshakeSession currentSession]) return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[HandshakeClient client] GET:@"/notifications/settings" parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [defaults setObject:responseObject[@"settings"] forKey:@"notifications_settings"];
        [defaults synchronize];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // do nothing
        NSLog(@"test");
    }];
}

- (void)updateSettings {
    // make sure logged in
    if (![HandshakeSession currentSession]) return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    [params addEntriesFromDictionary:[defaults dictionaryForKey:@"notifications_settings"]];
    [[HandshakeClient client] PUT:@"/notifications/settings" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [defaults setObject:responseObject[@"settings"] forKey:@"notifications_settings"];
        [defaults synchronize];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // do nothing
        NSLog(@"test");
    }];
}

- (void)handleNotification:(NSDictionary *)userInfo completionBlock:(void (^)())completionBlock {
    // make sure logged in
    if (![HandshakeSession currentSession]) {
        if (completionBlock) completionBlock();
        return;
    }
    
    if (userInfo[@"user"]) {
        [UserServerSync cacheUsers:@[userInfo[@"user"]] completionBlock:^(NSArray *users) {
            // if application inactive - open the user
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(openUser:)])
                    [self.delegate openUser:users[0]];
            } else {
                [FeedItemServerSync sync];
                // display alert
            }
            
            [ContactSync sync];
            
            if (completionBlock) completionBlock();
        }];
    } else
        if (completionBlock) completionBlock();
}

@end
