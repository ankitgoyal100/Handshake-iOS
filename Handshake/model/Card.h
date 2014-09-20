//
//  Card.h
//  Handshake
//
//  Created by Sam Ober on 9/17/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Contact, Email, Phone, Social, User;

typedef enum {
    CardSynced = 0,
    CardCreated,
    CardUpdated,
    CardDeleted
} CardSyncStatus;

static NSString * const CardSyncCompleted = @"CardSyncCompleted";

@interface Card : NSManagedObject

@property (nonatomic, retain) NSNumber * cardId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSOrderedSet *addresses;
@property (nonatomic, retain) Contact *contact;
@property (nonatomic, retain) NSOrderedSet *emails;
@property (nonatomic, retain) NSOrderedSet *phones;
@property (nonatomic, retain) NSOrderedSet *socials;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSNumber *cardOrder;

+ (void)sync;
+ (void)syncWithSuccessBlock:(void (^)())successBlock;

- (void)updateFromDictionary:(NSDictionary *)dictionary;
- (void)updateFromCard:(Card *)card;

- (Card *)createCopy;

- (NSString *)formattedName;
- (void)cleanEmptyFields;

- (NSDictionary *)dictionary;

@end

@interface Card (CoreDataGeneratedAccessors)

- (void)insertObject:(Address *)value inAddressesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAddressesAtIndex:(NSUInteger)idx;
- (void)insertAddresses:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAddressesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAddressesAtIndex:(NSUInteger)idx withObject:(Address *)value;
- (void)replaceAddressesAtIndexes:(NSIndexSet *)indexes withAddresses:(NSArray *)values;
- (void)addAddressesObject:(Address *)value;
- (void)removeAddressesObject:(Address *)value;
- (void)addAddresses:(NSOrderedSet *)values;
- (void)removeAddresses:(NSOrderedSet *)values;
- (void)insertObject:(Email *)value inEmailsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEmailsAtIndex:(NSUInteger)idx;
- (void)insertEmails:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEmailsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEmailsAtIndex:(NSUInteger)idx withObject:(Email *)value;
- (void)replaceEmailsAtIndexes:(NSIndexSet *)indexes withEmails:(NSArray *)values;
- (void)addEmailsObject:(Email *)value;
- (void)removeEmailsObject:(Email *)value;
- (void)addEmails:(NSOrderedSet *)values;
- (void)removeEmails:(NSOrderedSet *)values;
- (void)insertObject:(Phone *)value inPhonesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhonesAtIndex:(NSUInteger)idx;
- (void)insertPhones:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePhonesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPhonesAtIndex:(NSUInteger)idx withObject:(Phone *)value;
- (void)replacePhonesAtIndexes:(NSIndexSet *)indexes withPhones:(NSArray *)values;
- (void)addPhonesObject:(Phone *)value;
- (void)removePhonesObject:(Phone *)value;
- (void)addPhones:(NSOrderedSet *)values;
- (void)removePhones:(NSOrderedSet *)values;
- (void)insertObject:(Social *)value inSocialsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSocialsAtIndex:(NSUInteger)idx;
- (void)insertSocials:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSocialsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSocialsAtIndex:(NSUInteger)idx withObject:(Social *)value;
- (void)replaceSocialsAtIndexes:(NSIndexSet *)indexes withSocials:(NSArray *)values;
- (void)addSocialsObject:(Social *)value;
- (void)removeSocialsObject:(Social *)value;
- (void)addSocials:(NSOrderedSet *)values;
- (void)removeSocials:(NSOrderedSet *)values;
@end
