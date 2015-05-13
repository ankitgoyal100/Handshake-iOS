//
//  SearchResult.m
//  Handshake
//
//  Created by Sam Ober on 5/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "SearchResult.h"
#import "Request.h"
#import "Contact.h"
#import "HandshakeCoreDataStore.h"

@implementation SearchResult

@dynamic tag;
@dynamic mutual;
@dynamic userId;
@dynamic firstName;
@dynamic lastName;
@dynamic picture;
@dynamic pictureData;
@dynamic request;
@dynamic contact;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.userId = dictionary[@"id"];
    self.firstName = dictionary[@"first_name"];
    self.lastName = dictionary[@"last_name"];
    
    if (!dictionary[@"picture"] || (dictionary[@"picture"] && (!self.picture || ![self.picture isEqualToString:dictionary[@"picture"]]))) {
        self.picture = dictionary[@"picture"];
        self.pictureData = nil;
    }
    
    self.mutual = dictionary[@"mutual"];
    
    if (dictionary[@"request"]) {
        // try to find request
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Request"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"requestId == %@", dictionary[@"request"][@"id"]];
        request.fetchLimit = 1;
        
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (results && [results count] == 1) {
            self.request = results[0];
        } else {
            self.request = [[Request alloc] initWithEntity:[NSEntityDescription entityForName:@"Request" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        }
        [self.request updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:dictionary[@"request"]]];
    } else
        self.request = nil;
    
    if (dictionary[@"contact"]) {
        // try to find contact
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"contactId == %@", dictionary[@"contact"][@"id"]];
        request.fetchLimit = 1;
        
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (results && [results count] == 1) {
            self.contact = results[0];
        } else {
            self.contact = [[Contact alloc] initWithEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        }
        
        [self.contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:dictionary[@"contact"]]];
    } else
        self.contact = nil;
}

- (NSString *)formattedName {
    if (self.firstName && self.lastName)
        return [self.firstName stringByAppendingString:[@" " stringByAppendingString:self.lastName]];
    if (self.firstName) return self.firstName;
    return self.lastName;
}

@end
