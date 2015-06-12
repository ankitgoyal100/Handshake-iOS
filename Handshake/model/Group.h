//
//  Group.h
//  
//
//  Created by Sam Ober on 6/12/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FeedItem, GroupMember;

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
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *feedItems;
@property (nonatomic, retain) NSOrderedSet *members;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addFeedItemsObject:(FeedItem *)value;
- (void)removeFeedItemsObject:(FeedItem *)value;
- (void)addFeedItems:(NSSet *)values;
- (void)removeFeedItems:(NSSet *)values;

- (void)insertObject:(GroupMember *)value inMembersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMembersAtIndex:(NSUInteger)idx;
- (void)insertMembers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMembersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMembersAtIndex:(NSUInteger)idx withObject:(GroupMember *)value;
- (void)replaceMembersAtIndexes:(NSIndexSet *)indexes withMembers:(NSArray *)values;
- (void)addMembersObject:(GroupMember *)value;
- (void)removeMembersObject:(GroupMember *)value;
- (void)addMembers:(NSOrderedSet *)values;
- (void)removeMembers:(NSOrderedSet *)values;
@end
