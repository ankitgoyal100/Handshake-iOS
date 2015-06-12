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

@implementation Group

@dynamic code;
@dynamic createdAt;
@dynamic groupId;
@dynamic name;
@dynamic syncStatus;
@dynamic updatedAt;
@dynamic feedItems;
@dynamic members;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.groupId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.name = dictionary[@"name"];
    self.code = dictionary[@"code"];
    
    [self removeMembers:self.members];
    
    for (NSDictionary *memberDict in dictionary[@"members"]) {
        GroupMember *member = [[GroupMember alloc] initWithEntity:[NSEntityDescription entityForName:@"GroupMember" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        // find or create User
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", memberDict[@"id"]];
        request.fetchLimit = 1;
        
        __block NSArray *results;
        
        [self.managedObjectContext performBlockAndWait:^{
            results = [self.managedObjectContext executeFetchRequest:request error:nil];
        }];
        
        User *user;
        
        if (results && [results count] == 1)
            user = results[0];
        else
            user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        [user updateFromDictionary:memberDict];
        member.user = user;
        
        [self addMembersObject:member];
    }
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
