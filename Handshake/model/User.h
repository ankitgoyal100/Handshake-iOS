//
//  User.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * confirmationSentAt;
@property (nonatomic, retain) NSDate * confirmedAt;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * unconfirmedEmail;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSSet *cards;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;

@end