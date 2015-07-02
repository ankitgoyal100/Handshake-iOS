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
#import "HandshakeCoreDataStore.h"
#import "FeedItemServerSync.h"
#import "ContactSync.h"
#import "Group.h"
#import "GroupServerSync.h"

@interface NotificationsHelper()

@property (nonatomic, copy) NotificationsRequestCompletionBlock completionBlock;

@end

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
    
    // compare token to previously registered token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *registeredToken = [defaults stringForKey:@"notifications_token"];
    if (registeredToken && [token isEqualToString:registeredToken]) {
        if (self.completionBlock) {
            self.completionBlock(YES);
            self.completionBlock = nil;
        }
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"token"] = token;
    params[@"platform"] = @"iphone";
    [[HandshakeClient client] POST:@"/devices" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // update registered token in user defaults
        [defaults setValue:token forKey:@"notifications_token"];
        [defaults synchronize];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // do nothing
    }];
    
    if (self.completionBlock) {
        self.completionBlock(YES);
        self.completionBlock = nil;
    }
}

- (void)registerFailed {
    if (self.completionBlock) {
        self.completionBlock(NO);
        self.completionBlock = nil;
    }
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
    
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    
    // make sure logged in
    if (![HandshakeSession currentSession]) {
        if (completionBlock) completionBlock();
        return;
    }
    
    if (userInfo[@"user"]) {
        [UserServerSync cacheUsers:@[userInfo[@"user"]] completionBlock:^(NSArray *users) {
            // if application inactive - open the user
            if (appState == UIApplicationStateInactive) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(openUser:)])
                    [self.delegate openUser:users[0]];
            }
            
            [FeedItemServerSync syncWithCompletionBlock:^{
                [ContactSync syncWithCompletionBlock:^{
                    // sync group members if required
                    if (userInfo[@"group_id"]) {
                        NSNumber *groupId = userInfo[@"group_id"];
                        
                        // fetch group and sync members
                        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
                        NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] mainManagedObjectContext];
                        request.predicate = [NSPredicate predicateWithFormat:@"groupId == %@", groupId];
                        
                        __block NSArray *results;
                        
                        [objectContext performBlockAndWait:^{
                            results = [objectContext executeFetchRequest:request error:nil];
                        }];
                        
                        if (results && [results count] == 1) {
                            Group *group = results[0];
                            
                            [GroupServerSync loadGroupMembers:group completionBlock:^{
                                if (completionBlock) completionBlock();
                            }];
                            
                            return;
                        }
                    }
                    
                    if (completionBlock) completionBlock();
                }];
            }];
        }];
    } else
        if (completionBlock) completionBlock();
}

- (NotificationsStatus)notificationsStatus {
    BOOL asked = [[NSUserDefaults standardUserDefaults] boolForKey:@"notifications_permissions"];
    BOOL enabled = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
    
    if (enabled) return NotificationsStatusGranted;
    if (!asked) return NotificationsStatusNotAsked;
    return NotificationsStatusRevoked;
}

- (void)requestNotificationsPermissionsWithCompletionBlock:(NotificationsRequestCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"notifications_permissions"];
    [defaults synchronize];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil]];
}

@end
