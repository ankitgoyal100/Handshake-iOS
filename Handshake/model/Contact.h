//
//  Contact.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Card.h"
#import "User.h"

static NSString * const ContactSyncCompleted = @"ContactSyncCompleted";

typedef enum {
    ContactSynced = 0,
    ContactCreated,
    ContactUpdated,
    ContactDeleted
} ContactSyncStatus;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSNumber * contactId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSSet *feedItems;
@property (nonatomic, retain) NSNumber *saved;
@property (nonatomic, retain) NSNumber *savesToPhone;

+ (void)sync;
+ (void)syncWithCompletionBlock:(void (^)())completionBlock;

+ (BOOL)syncing;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

- (NSString *)firstLetter;

@end
