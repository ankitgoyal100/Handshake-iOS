//
//  Group.m
//  
//
//  Created by Sam Ober on 6/12/15.
//
//

#import "Group.h"
#import "FeedItem.h"
#import "GroupMember.h"
#import "HandshakeCoreDataStore.h"
#import "DateConverter.h"
#import "User.h"
#import "GroupMember.h"
#import "UserServerSync.h"

@implementation Group

@dynamic code;
@dynamic createdAt;
@dynamic groupId;
@dynamic name;
@dynamic syncStatus;
@dynamic updatedAt;
@dynamic feedItems;
@dynamic members;
@dynamic savesToPhone;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.groupId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.name = dictionary[@"name"];
    self.code = dictionary[@"code"];
}

+ (Group *)findOrCreateById:(NSNumber *)groupId inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"groupId == %@", groupId];
    request.fetchLimit = 1;
    
    __block NSArray *results;
    
    [context performBlockAndWait:^{
        results = [context executeFetchRequest:request error:nil];
    }];
    
    if (results && [results count] == 1) return results[0];
    
    Group *group = [[Group alloc] initWithEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    group.groupId = groupId;
    return group;
}

/// FIXES

- (void)addMembersObject:(GroupMember *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"members"];
    [tempSet addObject:value];
}

- (void)removeMembersObject:(GroupMember *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"members"];
    [tempSet removeObject:value];
}

- (void)addMembers:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"members"];
    [tempSet addObjectsFromArray:[values array]];
}

- (void)removeMembers:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"members"];
    [tempSet removeObjectsInArray:[values array]];
}

@end
