//
//  GroupMember.m
//  Handshake
//
//  Created by Sam Ober on 4/1/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "GroupMember.h"
#import "User.h"
#import "DateConverter.h"
#import "User.h"

@implementation GroupMember

@dynamic createdAt;
@dynamic groupMemberId;
@dynamic updatedAt;
@dynamic group;
@dynamic user;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.groupMemberId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    
    // try to find user
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", dictionary[@"user"][@"id"]];
    
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error && [results count] > 0) {
        User *user = results[0];
        
        [user updateFromDictionary:dictionary[@"user"]];
        self.user = user;
    } else {
        User *user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        [user updateFromDictionary:dictionary[@"user"]];
        self.user = user;
    }
}

@end
