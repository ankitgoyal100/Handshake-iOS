//
//  NotificationsHelper.h
//  Handshake
//
//  Created by Sam Ober on 6/17/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@protocol NotificationsHelperDelegate <NSObject>

- (void)openUser:(User *)user;

@end

@interface NotificationsHelper : NSObject

+ (NotificationsHelper *)sharedHelper;

- (void)registerDevice:(NSString *)token;

- (void)syncSettings;
- (void)updateSettings;

- (void)handleNotification:(NSDictionary *)userInfo completionBlock:(void (^)())completionBlock;

@property (nonatomic, strong) id <NotificationsHelperDelegate> delegate;

@end
