//
//  Card.m
//  Handshake
//
//  Created by Sam Ober on 9/17/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Card.h"
#import "Address.h"
#import "Email.h"
#import "Phone.h"
#import "Social.h"
#import "DateConverter.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "User.h"

static BOOL syncing = NO;

@implementation Card

@dynamic cardId;
@dynamic createdAt;
@dynamic name;
@dynamic syncStatus;
@dynamic updatedAt;
@dynamic addresses;
@dynamic emails;
@dynamic phones;
@dynamic socials;
@dynamic user;

+ (void)sync {
    [self syncWithSuccessBlock:nil];
}

+ (void)syncWithSuccessBlock:(void (^)())successBlock {
    if (syncing)
        return;
    
    syncing = YES;
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // retrieve all cards
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"GET" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:@"/cards"] absoluteString] parameters:[[HandshakeSession currentSession] credentials] error:nil]];
        operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        operation.responseSerializer = [HandshakeClient client].responseSerializer;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // get account
            Account *account = [[HandshakeSession currentSession] account];
            
            if (!account) {
                // no current account found - stop sync
                dispatch_async(dispatch_get_main_queue(), ^{
                    syncing = NO;
                    if (successBlock) successBlock();
                });
                return;
            }
            
            // get account in background context
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Account"];
            request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", account.userId];
            request.fetchLimit = 1;
            
            __block NSArray *results = nil;
            
            __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
            
            [objectContext performBlockAndWait:^{
                NSError *error;
                results = [objectContext executeFetchRequest:request error:&error];
            }];
            
            if (![results count]) {
                // no current account found - stop sync
                dispatch_async(dispatch_get_main_queue(), ^{
                    syncing = NO;
                    if (successBlock) successBlock();
                });
                return;
            }
            
            account = results[0];
            
            // map cards to ids
            NSMutableDictionary *cards = [[NSMutableDictionary alloc] init];
            for (NSDictionary *cardDict in responseObject[@"cards"]) {
                cards[cardDict[@"id"]] = cardDict;
            }
            
            // get the current cards
            results = [account.cards array];
            
            // update/delete records
            for (Card *card in results) {
                // if card is new skip
                if ([card.syncStatus intValue] == CardCreated) continue;
                
                NSDictionary *cardDict = cards[card.cardId];
                
                if (!cardDict) {
                    // record doesn't exist on server - delete card
                    [account removeCardsObject:card];
                    [objectContext deleteObject:card];
                } else {
                    // update if card is newer
                    if ([[DateConverter convertToDate:cardDict[@"updated_at"]] timeIntervalSinceDate:card.updatedAt] > 0) {
                        [card updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:cardDict]];
                        card.syncStatus = [NSNumber numberWithInt:CardSynced];
                    }
                }
                
                [cards removeObjectForKey:card.cardId];
            }
            
            // any remaining cards are new
            for (NSNumber *cardId in [cards allKeys]) {
                NSDictionary *cardDict = cards[cardId];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:objectContext];
                Card *card = [[Card alloc] initWithEntity:entity insertIntoManagedObjectContext:objectContext];
                
                [card updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:cardDict]];
                card.syncStatus = [NSNumber numberWithInt:CardSynced];
                
                [account addCardsObject:card];
            }
            
            // sync current cards with server
            
            request = [[NSFetchRequest alloc] initWithEntityName:@"Card"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"syncStatus!=%@ AND user==%@", [NSNumber numberWithInt:CardSynced], account];
            
            [objectContext performBlockAndWait:^{
                NSError *error;
                results = [objectContext executeFetchRequest:request error:&error];
            }];
            
            if (!results) {
                // error - stop sync
                dispatch_async(dispatch_get_main_queue(), ^{
                    syncing = NO;
                    if (successBlock) successBlock();
                });
                return;
            }
            
            NSMutableArray *operations = [[NSMutableArray alloc] init];
            
            for (Card *card in results) {
                // create, update, or delete cards
                if ([card.syncStatus intValue] == CardCreated) {
                    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
                    [params addEntriesFromDictionary:[card dictionary]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"POST" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:@"/cards"] absoluteString] parameters:params error:nil]];
                
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                    operation.responseSerializer = [HandshakeClient client].responseSerializer;
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [card updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"card"]]];
                        card.syncStatus = [NSNumber numberWithInt:CardSynced];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        // do nothing
                    }];
                    [operations addObject:operation];
                } else if ([card.syncStatus intValue] == CardUpdated) {
                    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
                    [params addEntriesFromDictionary:[card dictionary]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"PUT" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/cards/%d", [card.cardId intValue]]] absoluteString] parameters:params error:nil]];
                    
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                    operation.responseSerializer = [HandshakeClient client].responseSerializer;
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [card updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"card"]]];
                        card.syncStatus = [NSNumber numberWithInt:CardSynced];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        // do nothing
                    }];
                    [operations addObject:operation];
                } else if ([card.syncStatus intValue] == CardDeleted) {
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"DELETE" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/cards/%d", [card.cardId intValue]]] absoluteString] parameters:[[HandshakeSession currentSession] credentials] error:nil]];
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                    operation.responseSerializer = [HandshakeClient client].responseSerializer;
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [objectContext deleteObject:card];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        // do nothing
                    }];
                    [operations addObject:operation];
                }
            }
            
            NSArray *preparedOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                // do nothing
            } completionBlock:^(NSArray *operations) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    // save
                    [objectContext performBlockAndWait:^{
                        [objectContext save:nil];
                    }];
                    [[HandshakeCoreDataStore defaultStore] saveMainContext];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // end sync
                        syncing = NO;
                        if (successBlock) successBlock();
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:CardSyncCompleted object:nil];
                    });
                });
            }];
            [[[NSOperationQueue alloc] init] addOperations:preparedOperations waitUntilFinished:NO];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                syncing = NO;
                if ([[operation response] statusCode] == 401) {
                    [[HandshakeSession currentSession] invalidate];
                } else {
                    // retry
                    [self syncWithSuccessBlock:successBlock];
                }
            });
        }];
        [operation start];
        //[[[NSOperationQueue alloc] init] addOperation:operation];
    });
}

+ (BOOL)syncing {
    return syncing;
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.cardId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.name = dictionary[@"name"];
    
    for (Phone *phone in self.phones) [self.managedObjectContext deleteObject:phone];
    [self removePhones:self.phones];
    for (NSDictionary *phoneDict in dictionary[@"phones"]) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phone" inManagedObjectContext:self.managedObjectContext];
        Phone *phone = [[Phone alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        phone.number = phoneDict[@"number"];
        phone.label = phoneDict[@"label"];
        
        [self addPhonesObject:phone];
    }
    
    for (Email *email in self.emails) [self.managedObjectContext deleteObject:email];
    [self removeEmails:self.emails];
    for (NSDictionary *emailDict in dictionary[@"emails"]) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Email" inManagedObjectContext:self.managedObjectContext];
        Email *email = [[Email alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        email.address = emailDict[@"address"];
        email.label = emailDict[@"label"];
        
        [self addEmailsObject:email];
    }
    
    for (Address *address in self.addresses) [self.managedObjectContext deleteObject:address];
    [self removeAddresses:self.addresses];
    for (NSDictionary *addressDict in dictionary[@"addresses"]) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address" inManagedObjectContext:self.managedObjectContext];
        Address *address = [[Address alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        address.street1 = addressDict[@"street1"];
        address.street2 = addressDict[@"street2"];
        address.city = addressDict[@"city"];
        address.state = addressDict[@"state"];
        address.zip = addressDict[@"zip"];
        address.label = addressDict[@"label"];
        
        [self addAddressesObject:address];
    }
    
    for (Social *social in self.socials) [self.managedObjectContext deleteObject:social];
    [self removeSocials:self.socials];
    for (NSDictionary *socialDict in dictionary[@"socials"]) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.managedObjectContext];
        Social *social = [[Social alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        social.username = socialDict[@"username"];
        social.network = socialDict[@"network"];
        
        [self addSocialsObject:social];
    }
}

- (void)updateFromCard:(Card *)card {
    self.cardId = card.cardId;
    self.createdAt = card.createdAt;
    self.updatedAt = card.updatedAt;
    self.name = card.name;
    
    for (Phone *phone in self.phones) [self.managedObjectContext deleteObject:phone];
    [self removePhones:self.phones];
    for (Phone *phone in card.phones) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phone" inManagedObjectContext:self.managedObjectContext];
        Phone *newPhone = [[Phone alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        newPhone.number = phone.number;
        newPhone.label = phone.label;
        
        [self addPhonesObject:newPhone];
    }
    
    for (Email *email in self.emails) [self.managedObjectContext deleteObject:email];
    [self removeEmails:self.emails];
    for (Email *email in card.emails) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Email" inManagedObjectContext:self.managedObjectContext];
        Email *newEmail = [[Email alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        newEmail.address = email.address;
        newEmail.label = email.label;
        
        [self addEmailsObject:newEmail];
    }
    
    for (Address *address in self.addresses) [self.managedObjectContext deleteObject:address];
    [self removeAddresses:self.addresses];
    for (Address *address in card.addresses) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address" inManagedObjectContext:self.managedObjectContext];
        Address *newAddress = [[Address alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        newAddress.street1 = address.street1;
        newAddress.street2 = address.street2;
        newAddress.city = address.city;
        newAddress.state = address.state;
        newAddress.zip = address.zip;
        newAddress.label = address.label;
        
        [self addAddressesObject:newAddress];
    }
    
    for (Social *social in self.socials) [self.managedObjectContext deleteObject:social];
    [self removeSocials:self.socials];
    for (Social *social in card.socials) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.managedObjectContext];
        Social *newSocial = [[Social alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        newSocial.username = social.username;
        newSocial.network = social.network;
        
        [self addSocialsObject:newSocial];
    }
}

- (Card *)createCopy {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.managedObjectContext];
    Card *card = [[Card alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    
    [card updateFromCard:self];
    return card;
}

- (void)cleanEmptyFields {
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    for (Phone *phone in self.phones) {
        if (![phone.number length] || ![phone.label length])
            [toRemove addObject:phone];
    }
    for (Phone *phone in toRemove) {
        [self removePhonesObject:phone];
        [self.managedObjectContext deleteObject:phone];
    }
    
    [toRemove removeAllObjects];
    
    for (Email *email in self.emails) {
        if (![email.address length] || ![email.label length])
            [toRemove addObject:email];
    }
    for (Email *email in toRemove) {
        [self removeEmailsObject:email];
        [self.managedObjectContext deleteObject:email];
    }
    
    [toRemove removeAllObjects];
    
    for (Address *address in self.addresses) {
        if ((![address.street1 length] && ![address.street2 length] && ![address.city length] && ![address.state length] && ![address.zip length]) || ![address.label length])
            [toRemove addObject:address];
    }
    for (Address *address in toRemove) {
        [self removeAddressesObject:address];
        [self.managedObjectContext deleteObject:address];
    }
    
    [toRemove removeAllObjects];
    
    for (Social *social in self.socials) {
        if (![social.username length] || ![social.network length])
            [toRemove addObject:social];
    }
    for (Social *social in toRemove) {
        [self removeSocialsObject:social];
        [self.managedObjectContext deleteObject:social];
    }
    
    [toRemove removeAllObjects];
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (self.name) dictionary[@"name"] = self.name;
    
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    for (Phone *phone in self.phones) {
        if ([phone.number length] && [phone.label length]) {
            NSMutableDictionary *phoneDict = [[NSMutableDictionary alloc] init];
            phoneDict[@"number"] = phone.number;
            phoneDict[@"label"] = phone.label;
            [phones addObject:phoneDict];
        }
    }
    dictionary[@"phones_attributes"] = phones;
    
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    for (Email *email in self.emails) {
        if ([email.address length] && [email.label length]) {
            NSMutableDictionary *emailDict = [[NSMutableDictionary alloc] init];
            emailDict[@"address"] = email.address;
            emailDict[@"label"] = email.label;
            [emails addObject:emailDict];
        }
    }
    dictionary[@"emails_attributes"] = emails;
    
    NSMutableArray *addresses = [[NSMutableArray alloc] init];
    for (Address *address in self.addresses) {
        if (([address.street1 length] || [address.street2 length] || [address.city length] || [address.state length] || [address.zip length]) && [address.label length]) {
            NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
            if (address.street1) addressDict[@"street1"] = address.street1;
            if (address.street2) addressDict[@"street2"] = address.street2;
            if (address.city) addressDict[@"city"] = address.city;
            if (address.state) addressDict[@"state"] = address.state;
            if (address.zip) addressDict[@"zip"] = address.zip;
            addressDict[@"label"] = address.label;
            [addresses addObject:addressDict];
        }
    }
    dictionary[@"addresses_attributes"] = addresses;
    
    NSMutableArray *socials = [[NSMutableArray alloc] init];
    for (Social *social in self.socials) {
        if ([social.username length] && [social.network length]) {
            NSMutableDictionary *socialDict = [[NSMutableDictionary alloc] init];
            socialDict[@"username"] = social.username;
            socialDict[@"network"] = social.network;
            [socials addObject:socialDict];
        }
    }
    dictionary[@"socials_attributes"] = socials;
    
    return dictionary;
}


/// FIXES

- (void)addPhonesObject:(Phone *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"phones"];
    [tempSet addObject:value];
}

- (void)removePhonesObject:(Phone *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"phones"];
    [tempSet removeObject:value];
}

- (void)addPhones:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"phones"];
    [tempSet addObjectsFromArray:[values array]];
}

- (void)removePhones:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"phones"];
    [tempSet removeObjectsInArray:[values array]];
}

- (void)addEmailsObject:(Email *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"emails"];
    [tempSet addObject:value];
}

- (void)removeEmailsObject:(Email *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"emails"];
    [tempSet removeObject:value];
}

- (void)addEmails:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"emails"];
    [tempSet addObjectsFromArray:[values array]];
}

- (void)removeEmails:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"emails"];
    [tempSet removeObjectsInArray:[values array]];
}

- (void)addAddressesObject:(Address *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"addresses"];
    [tempSet addObject:value];
}

- (void)removeAddressesObject:(Address *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"addresses"];
    [tempSet removeObject:value];
}

- (void)addAddresses:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"addresses"];
    [tempSet addObjectsFromArray:[values array]];
}

- (void)removeAddresses:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"addresses"];
    [tempSet removeObjectsInArray:[values array]];
}

- (void)addSocialsObject:(Social *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"socials"];
    [tempSet addObject:value];
}

- (void)removeSocialsObject:(Social *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"socials"];
    [tempSet removeObject:value];
}

- (void)addSocials:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"socials"];
    [tempSet addObjectsFromArray:[values array]];
}

- (void)removeSocials:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"socials"];
    [tempSet removeObjectsInArray:[values array]];
}

@end
