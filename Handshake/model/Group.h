//
//  Group.h
//  Handshake
//
//  Created by Sam Ober on 5/3/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GroupMember;

typedef enum {
    GroupSynced = 0,
    GroupCreated,
    GroupUpdated,
    GroupDeleted
} GroupSyncStatus;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSSet *members;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

+ (void)sync;
+ (void)syncWithCompletionBlock:(void (^)())completionBlock;

@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addMembersObject:(GroupMember *)value;
- (void)removeMembersObject:(GroupMember *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end
