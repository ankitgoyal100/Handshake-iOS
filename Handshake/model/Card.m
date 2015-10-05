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
        phone.countryCode = phoneDict[@"country_code"];
        
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
        newPhone.countryCode = phone.countryCode;
        
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
            phoneDict[@"country_code"] = phone.countryCode;
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
