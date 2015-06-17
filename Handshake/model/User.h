//
//  User.h
//  Handshake
//
//  Created by Sam Ober on 4/4/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class Card, GroupMember, Request, SearchResult, Suggestion;

typedef enum {
    UserSynced = 0,
    UserCreated,
    UserUpdated,
    UserDeleted
} UserSyncStatus;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;

@property (nonatomic, retain) NSDate *contactUpdated;

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;

@property (nonatomic, retain) NSString *thumb;
@property (nonatomic, retain) NSData *thumbData;

@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSData * pictureData;

@property (nonatomic, retain) NSNumber *isContact;
@property (nonatomic, retain) NSNumber *requestSent;
@property (nonatomic, retain) NSNumber *requestReceived;

@property (nonatomic, retain) NSNumber *contacts;
@property (nonatomic, retain) NSNumber *mutual;

@property (nonatomic, retain) NSNumber *syncStatus;
@property (nonatomic, retain) NSNumber *saved;
@property (nonatomic, retain) NSNumber *savesToPhone;

@property (nonatomic, retain) NSOrderedSet *cards;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *feedItems;
@property (nonatomic, retain) Suggestion *suggestion;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionary;
- (NSString *)formattedName;

- (NSString *)firstLetterOfName;

- (UIImage *)cachedImage;
- (UIImage *)cachedThumb;

+ (User *)findOrCreateById:(NSNumber *)userId inContext:(NSManagedObjectContext *)context;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)insertObject:(Card *)value inCardsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCardsAtIndex:(NSUInteger)idx;
- (void)insertCards:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCardsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCardsAtIndex:(NSUInteger)idx withObject:(Card *)value;
- (void)replaceCardsAtIndexes:(NSIndexSet *)indexes withCards:(NSArray *)values;
- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSOrderedSet *)values;
- (void)removeCards:(NSOrderedSet *)values;
- (void)addGroupsObject:(GroupMember *)value;
- (void)removeGroupsObject:(GroupMember *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
