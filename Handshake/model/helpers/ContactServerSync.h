//
//  ContactServerSync.h
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

static NSString * const ContactSyncCompleted = @"ContactSyncCompleted";

@interface ContactServerSync : NSObject

+ (void)sync;
+ (void)syncWithCompletionBlock:(void (^)())completionBlock;

+ (void)deleteContact:(User *)user;

@end
