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
#import <AddressBook/AddressBook.h>
#import "HandshakeClient.h"
#import "HandshakeSession.h"

static BOOL syncing = NO;

@implementation SearchResult

@dynamic tag;
@dynamic request;
@dynamic contact;
@dynamic user;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
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
    
    if (self.contact)
        self.user = self.contact.user;
    else {
        if (!self.user) {
            // try to find user
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", dictionary[@"id"]];
            request.fetchLimit = 1;
            
            NSError *error;
            NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
            
            if (results && [results count] == 1) {
                self.user = results[0];
            } else {
                self.user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
            }
        }
        
        self.user.userId = dictionary[@"id"];
        self.user.firstName = dictionary[@"first_name"];
        self.user.lastName = dictionary[@"last_name"];
        self.user.contacts = dictionary[@"contacts"];
        self.user.mutual = dictionary[@"mutual"];
        
        if (!dictionary[@"picture"] || (dictionary[@"picture"] && (!self.user.picture || ![self.user.picture isEqualToString:dictionary[@"picture"]]))) {
            self.user.picture = dictionary[@"picture"];
            self.user.pictureData = nil;
        }
    }
}

+ (void)syncSuggestions {
    [self syncSuggestionsWithCompletionBlock:nil];
}

+ (void)syncSuggestionsWithCompletionBlock:(void (^)())completionBlock {
    if (syncing) return;
    
    syncing = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (!addressBook) { // sync failed
            dispatch_async(dispatch_get_main_queue(), ^{
                syncing = NO;
                if (completionBlock) completionBlock();
            });
            
            return;
        }
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (!granted) { // sync failed
                dispatch_async(dispatch_get_main_queue(), ^{
                    syncing = NO;
                    if (completionBlock) completionBlock();
                });
                
                return;
            }
            
            NSMutableArray *phones = [[NSMutableArray alloc] init];
            NSMutableArray *emails = [[NSMutableArray alloc] init];
            
            NSArray *contacts = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
            NSInteger count = [contacts count];
            
            for (int i = 0; i < count; i++) {
                ABRecordRef contact = (__bridge ABRecordRef)contacts[i];
                
                // add phones
                
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(contact, kABPersonPhoneProperty);
                CFIndex numPhones = ABMultiValueGetCount(phoneNumbers);
                
                for (CFIndex index = 0; index < numPhones; index++) {
                    NSString *number = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, index));
                    number = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                    [phones addObject:number];
                }
                
                CFRelease(phoneNumbers);
                
                // add emails
                
                ABMultiValueRef emailAddresses = ABRecordCopyValue(contact, kABPersonEmailProperty);
                CFIndex numEmails = ABMultiValueGetCount(emailAddresses);
                
                for (CFIndex index = 0; index < numEmails; index++) {
                    NSString *email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emailAddresses, index));
                    [emails addObject:email];
                }
                
                CFRelease(emailAddresses);
            }
            
            // get suggestions
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
            params[@"phones"] = phones;
            params[@"emails"] = emails;
            [[HandshakeClient client] POST:@"/search/suggestions" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                // find/create search results
                
                __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
                
                for (NSDictionary *dict in responseObject[@"results"]) {
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SearchResult"];
                    
                    request.predicate = [NSPredicate predicateWithFormat:@"user.userId == %@", dict[@"id"]];
                    request.fetchLimit = 1;
                    
                    __block NSArray *results;
                    
                    [objectContext performBlockAndWait:^{
                        NSError *error;
                        results = [objectContext executeFetchRequest:request error:&error];
                    }];
                    
                    SearchResult *result;
                    
                    if (results && [results count] == 1) {
                        result = results[0];
                    } else {
                        result = [[SearchResult alloc] initWithEntity:[NSEntityDescription entityForName:@"SearchResult" inManagedObjectContext:objectContext] insertIntoManagedObjectContext:objectContext];
                    }
                    
                    [result updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:dict]];
                    result.tag = @"suggestion";
                }
                
                // save
                [objectContext performBlockAndWait:^{
                    [objectContext save:nil];
                }];
                [[HandshakeCoreDataStore defaultStore] saveMainContext];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    syncing = NO;
                    if (completionBlock) completionBlock();
                });
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[operation response] statusCode] == 401) {
                        [[HandshakeSession currentSession] invalidate];
                    }
                    
                    syncing = NO;
                    if (completionBlock) completionBlock();
                });
            }];
        });
        
    });
}

@end
