//
//  Card.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeCard.h"
#import "DateConverter.h"

@implementation HandshakeCard

- (NSMutableArray *)phones {
    if (!_phones) _phones = [[NSMutableArray alloc] init];
    return _phones;
}

- (NSMutableArray *)emails {
    if (!_emails) _emails = [[NSMutableArray alloc] init];
    return _emails;
}

- (NSMutableArray *)addresses {
    if (!_addresses) _addresses = [[NSMutableArray alloc] init];
    return _addresses;
}

- (NSMutableArray *)socials {
    if (!_socials) _socials = [[NSMutableArray alloc] init];
    return _socials;
}

+ (HandshakeCard *)cardFromDictionary:(NSDictionary *)dict {
    HandshakeCard *card = [[HandshakeCard alloc] init];
    card.cardId = [[dict objectForKey:@"id"] longValue];
    card.createdAt = [DateConverter convertToDate:[dict objectForKey:@"created_at"]];
    card.updatedAt = [DateConverter convertToDate:[dict objectForKey:@"updated_at"]];
    card.name = [dict objectForKey:@"name"];
    if ([card.name isKindOfClass:[NSNull class]]) card.name = nil;
    card.firstName = [dict objectForKey:@"first_name"];
    if ([card.firstName isKindOfClass:[NSNull class]]) card.firstName = nil;
    card.lastName = [dict objectForKey:@"last_name"];
    if ([card.lastName isKindOfClass:[NSNull class]]) card.lastName = nil;
    card.picture = [dict objectForKey:@"picture"];
    if ([card.picture isKindOfClass:[NSNull class]]) card.picture = nil;
    
    // loop through phones
    for (NSDictionary *phoneDict in [dict objectForKey:@"phones"]) {
        HandshakePhone *phone = [[HandshakePhone alloc] init];
        phone.label = [phoneDict objectForKey:@"label"];
        if ([phone.label isKindOfClass:[NSNull class]]) phone.label = nil;
        phone.number = [phoneDict objectForKey:@"number"];
        if ([phone.number isKindOfClass:[NSNull class]]) phone.number = nil;
        [card.phones addObject:phone];
    }
    
    // loop through emails
    for (NSDictionary *emailDict in [dict objectForKey:@"emails"]) {
        HandshakeEmail *email = [[HandshakeEmail alloc] init];
        email.label = [emailDict objectForKey:@"label"];
        if ([email.label isKindOfClass:[NSNull class]]) email.label = nil;
        email.address = [emailDict objectForKey:@"address"];
        if ([email.address isKindOfClass:[NSNull class]]) email.address = nil;
        [card.emails addObject:email];
    }
    
    // loop through socials
    for (NSDictionary *socialDict in [dict objectForKey:@"socials"]) {
        HandshakeSocial *social = [[HandshakeSocial alloc] init];
        social.network = [socialDict objectForKey:@"network"];
        if ([social.network isKindOfClass:[NSNull class]]) social.network = nil;
        social.username = [socialDict objectForKey:@"username"];
        if ([social.username isKindOfClass:[NSNull class]]) social.username = nil;
        [card.socials addObject:social];
    }
    
    // loop through addresses
    for (NSDictionary *addressDict in [dict objectForKey:@"addresses"]) {
        HandshakeAddress *address = [[HandshakeAddress alloc] init];
        address.label = [addressDict objectForKey:@"label"];
        if ([address.label isKindOfClass:[NSNull class]]) address.label = nil;
        address.street1 = [addressDict objectForKey:@"street1"];
        if ([address.street1 isKindOfClass:[NSNull class]]) address.street1 = nil;
        address.street2 = [addressDict objectForKey:@"street2"];
        if ([address.street2 isKindOfClass:[NSNull class]]) address.street2 = nil;
        address.city = [addressDict objectForKey:@"city"];
        if ([address.city isKindOfClass:[NSNull class]]) address.city = nil;
        address.state = [addressDict objectForKey:@"state"];
        if ([address.state isKindOfClass:[NSNull class]]) address.state = nil;
        address.zip = [addressDict objectForKey:@"zip"];
        if ([address.zip isKindOfClass:[NSNull class]]) address.zip = nil;
        [card.addresses addObject:address];
    }
    
    [card clean];
    
    return card;
}

+ (NSDictionary *)dictionaryFromCard:(HandshakeCard *)card {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [card clean];
    
    if (card.firstName) dict[@"first_name"] = card.firstName;
    if (card.lastName) dict[@"last_name"] = card.lastName;
    if (card.picture) dict[@"picture"] = card.picture;
    if (card.name) dict[@"name"] = card.name;
    
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    for (HandshakePhone *phone in card.phones) {
        NSMutableDictionary *phoneDict = [[NSMutableDictionary alloc] init];
        if (phone.number) phoneDict[@"number"] = phone.number;
        if (phone.label) phoneDict[@"label"] = phone.label;
        [phones addObject:phoneDict];
    }
    dict[@"phones_attributes"] = phones;
    
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    for (HandshakeEmail *email in card.emails) {
        NSMutableDictionary *emailDict = [[NSMutableDictionary alloc] init];
        if (email.address) emailDict[@"address"] = email.address;
        if (email.label) emailDict[@"label"] = email.label;
        [emails addObject:emailDict];
    }
    dict[@"emails_attributes"] = emails;
    
    NSMutableArray *addresses = [[NSMutableArray alloc] init];
    for (HandshakeAddress *address in card.addresses) {
        NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
        if (address.street1) addressDict[@"street1"] = address.street1;
        if (address.street2) addressDict[@"street2"] = address.street2;
        if (address.city) addressDict[@"city"] = address.city;
        if (address.state) addressDict[@"state"] = address.state;
        if (address.zip) addressDict[@"zip"] = address.zip;
        if (address.label) addressDict[@"label"] = address.label;
        [addresses addObject:addressDict];
    }
    dict[@"addresses_attributes"] = addresses;
    
    NSMutableArray *socials = [[NSMutableArray alloc] init];
    for (HandshakeSocial *social in card.socials) {
        NSMutableDictionary *socialDict = [[NSMutableDictionary alloc] init];
        if (social.username) socialDict[@"username"] = social.username;
        if (social.network) socialDict[@"network"] = social.network;
        [socials addObject:socialDict];
    }
    dict[@"socials_attributes"] = socials;
    
    return dict;
}

- (NSString *)formattedName {
    if (self.firstName && self.lastName)
        return [self.firstName stringByAppendingString:[@" " stringByAppendingString:self.lastName]];
    if (self.firstName) return self.firstName;
    return self.lastName;
}

- (HandshakeCard *)createCopy {
    HandshakeCard *card = [[HandshakeCard alloc] init];
    
    card.cardId = self.cardId;
    card.createdAt = self.createdAt;
    card.updatedAt = self.updatedAt;
    card.name = self.name;
    card.firstName = self.firstName;
    card.lastName = self.lastName;
    card.picture = self.picture;
    
    for (HandshakePhone *phone in self.phones)
        [card.phones addObject:[[HandshakePhone alloc] initWithNumber:phone.number label:phone.label]];
    
    for (HandshakeEmail *email in self.emails)
        [card.emails addObject:[[HandshakeEmail alloc] initWithAddress:email.address label:email.label]];
    
    for (HandshakeAddress *address in self.addresses)
        [card.addresses addObject:[[HandshakeAddress alloc] initWithStreet1:address.street1 street2:address.street2 city:address.city state:address.state zip:address.zip label:address.label]];
    
    for (HandshakeSocial *social in self.socials)
        [card.socials addObject:[[HandshakeSocial alloc] initWithUsername:social.username network:social.network]];
    
    return card;
}

- (void)setToCard:(HandshakeCard *)card {
    self.cardId = card.cardId;
    self.createdAt = card.createdAt;
    self.updatedAt = card.updatedAt;
    self.name = card.name;
    self.firstName = card.firstName;
    self.lastName = card.lastName;
    self.picture = card.picture;
    
    [self.phones removeAllObjects];
    for (HandshakePhone *phone in card.phones)
        [self.phones addObject:[[HandshakePhone alloc] initWithNumber:phone.number label:phone.label]];
    
    [self.emails removeAllObjects];
    for (HandshakeEmail *email in card.emails)
        [self.emails addObject:[[HandshakeEmail alloc] initWithAddress:email.address label:email.label]];
    
    [self.addresses removeAllObjects];
    for (HandshakeAddress *address in card.addresses)
        [self.addresses addObject:[[HandshakeAddress alloc] initWithStreet1:address.street1 street2:address.street2 city:address.city state:address.state zip:address.zip label:address.label]];
    
    [self.socials removeAllObjects];
    for (HandshakeSocial *social in card.socials)
        [self.socials addObject:[[HandshakeSocial alloc] initWithUsername:social.username network:social.network]];
}

- (void)clean {
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    for (HandshakePhone *phone in self.phones)
        if (!phone.number || phone.number.length == 0) [toRemove addObject:phone];
    for (HandshakePhone *phone in toRemove)
        [self.phones removeObject:phone];
    
    [toRemove removeAllObjects];
    
    for (HandshakeEmail *email in self.emails)
        if (!email.address || email.address.length == 0) [toRemove addObject:email];
    for (HandshakeEmail *email in toRemove)
        [self.emails removeObject:email];
    
    [toRemove removeAllObjects];
    
    for (HandshakeAddress *address in self.addresses)
        if ([address formattedString].length == 0) [toRemove addObject:address];
    for (HandshakeAddress *address in toRemove)
        [self.addresses removeObject:address];
    
    [toRemove removeAllObjects];
    
    for (HandshakeSocial *social in self.socials)
        if (!social.username || social.username.length == 0 || !social.network || social.network.length == 0) [toRemove addObject:social];
    for (HandshakeSocial *social in toRemove)
        [self.socials removeObject:social];
    
    [toRemove removeAllObjects];
}

@end
