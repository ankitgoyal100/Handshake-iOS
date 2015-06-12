//
//  GroupMember.h
//  Handshake
//
//  Created by Sam Ober on 4/1/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;
@class Group;

@interface GroupMember : NSManagedObject

@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) User *user;

@end
