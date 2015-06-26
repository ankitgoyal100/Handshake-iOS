//
//  NotificationsHelper.h
//  Handshake
//
//  Created by Sam Ober on 6/17/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef enum {
    NotificationsStatusNotAsked = 0,
    NotificationsStatusGranted,
    NotificationsStatusRevoked
} NotificationsStatus;

typedef void (^NotificationsRequestCompletionBlock)(BOOL success);

@protocol NotificationsHelperDelegate <NSObject>

- (void)openUser:(User *)user;

@end

@interface NotificationsHelper : NSObject

+ (NotificationsHelper *)sharedHelper;

- (void)registerDevice:(NSString *)token;
- (void)registerFailed;

- (void)syncSettings;
- (void)updateSettings;

- (void)handleNotification:(NSDictionary *)userInfo completionBlock:(void (^)())completionBlock;

- (NotificationsStatus)notificationsStatus;
- (void)requestNotificationsPermissionsWithCompletionBlock:(NotificationsRequestCompletionBlock)completionBlock;

@property (nonatomic, strong) id <NotificationsHelperDelegate> delegate;

@end
