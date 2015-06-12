//
//  FeedItem.h
//  Handshake
//
//  Created by Sam Ober on 6/1/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User, Group;

@interface FeedItem : NSManagedObject

@property (nonatomic, retain) NSNumber * feedId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * itemType;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Group *group;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end
