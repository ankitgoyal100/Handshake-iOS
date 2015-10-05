//
//  ContactSync.m
//  Handshake
//
//  Created by Sam Ober on 6/10/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "ContactSync.h"
#import "HandshakeCoreDataStore.h"
#import "Card.h"
#import "User.h"
#import "Phone.h"
#import "Email.h"
#import "Address.h"
#import "Social.h"
#import "AsyncImageView.h"
#import "NBPhoneNumberUtil.h"
#import <Contacts/Contacts.h>

@implementation ContactSync

+ (AddressBookStatus)addressBookStatus {
    BOOL asked = [[NSUserDefaults standardUserDefaults] boolForKey:@"address_book_permissions"];
    BOOL granted = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized;
    
    if (!asked) return AddressBookStatusNotAsked;
    if (asked && granted) return AddressBookStatusGranted;
    return AddressBookStatusRevoked;
}

+ (void)requestAddressBookAccessWithCompletionBlock:(void (^)(BOOL))completionBlock {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        if (completionBlock) completionBlock(YES);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"address_book_permissions"];
        [defaults synchronize];
        
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted && completionBlock)
                    completionBlock(YES);
                else if (completionBlock)
                    completionBlock(NO);
            });
        }];
    });
}

+ (void)syncAll {
    // set all contacts to unsaved
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"isContact == %@", @(YES)];
    
    __block NSArray *results;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:nil];
    }];
    
    if (!results) return;
    
    for (User *contact in results)
        contact.saved = @(NO);
    
    [self sync];
}

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())completionBlock {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusAuthorized) {
        if (completionBlock) {
            completionBlock();
        }
    }
    
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto_sync"];
    
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t p = 0;
    
    if (!queue) {
        dispatch_once(&p, ^{
            queue = dispatch_queue_create("handshake_contact_download_queue", NULL);
        });
    }
    
    dispatch_async(queue, ^{
        NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        // get contacts
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        
        if ([settings[@"enabled"] boolValue])
            request.predicate = [NSPredicate predicateWithFormat:@"isContact == %@ AND saved == %@", @(YES), @(NO)];
        else
            request.predicate = [NSPredicate predicateWithFormat:@"isContact == %@ AND saved == %@ AND savesToPhone == %@", @(YES), @(NO), @(YES)];
        
        __block NSArray *results;
        
        [objectContext performBlockAndWait:^{
            results = [objectContext executeFetchRequest:request error:nil];
        }];
        
        if (!results) {
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
            }
            return; // something went wrong
        }
        
        CNContactStore *store = [[CNContactStore alloc] init];
        
        for (User *contact in results)
            [self syncContact:contact toContactStore:store];
        
        // save
        [objectContext performBlockAndWait:^{
            [objectContext save:nil];
        }];
        [[HandshakeCoreDataStore defaultStore] saveMainContext];
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}

+ (void)syncContact:(User *)contact toContactStore:(CNContactStore *)contactStore {
    if ([contact.cards count] == 0) return;
    
    Card *card = contact.cards[0];
    
    if ([card.phones count] + [card.emails count] + [card.addresses count] + [card.socials count] == 0) return; // no information to sync
    
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto_sync"];
    
    NSError *error;
    NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:[contactStore defaultContainerIdentifier]];
    NSArray *contacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactImageDataAvailableKey,CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactSocialProfilesKey] error:&error];
    
    if (error != nil) return;
    
    // find record to update
    
    CNContact *record = nil;
    int matches = 0; // count of how many contacts have matching data
    
    for (int i = 0; i < [contacts count]; i++) {
        CNContact *r = contacts[i];
        int certainty = 0; // count of how many data points match
        BOOL nameMatch = NO;
    
        // check name
    
        NSString *name = [r.givenName stringByAppendingString:[@" " stringByAppendingString:r.familyName]];
        if ([name containsString:contact.firstName]) {
            nameMatch = YES;
            certainty++;
        }
   
        // check phones
        
        for (CNLabeledValue *number in r.phoneNumbers) {
            NSString *numberString = ((CNPhoneNumber *)number.value).stringValue;
            numberString = [[numberString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            
            for (Phone *phone in card.phones) {
                if ([phone.number hasSuffix:numberString]) {
                    // match
                    certainty++;
                    break;
                }
            }
        }
        
        
        // check emails
        
        for (CNLabeledValue *email in r.emailAddresses) {
            NSString *address = email.value;
            
            for (Email *email in card.emails) {
                if ([address isEqualToString:email.address]) {
                    // match
                    certainty++;
                    break;
                }
            }
        }
        
        // check social networks
        
        for (CNLabeledValue *social in r.socialProfiles) {
            NSString *username = ((CNSocialProfile *)social.value).username;
            
            for (Social *social in card.socials) {
                if ([social.username isEqualToString:username]) {
                    // match
                    certainty++;
                    break;
                }
            }
        }
        
        // require 2 certainty points for guaranteed match
        if (certainty >= 2) {
            record = r;
            matches = 1; // we are certain
            break;
        } else if (!nameMatch && certainty == 1) { // cannot say match solely based on first name
            record = r;
            matches++;
        }
    }
    
    BOOL newRecord = NO;
    CNMutableContact *mutableRecord;
    
    if (!record || matches != 1) { // if no record found or multiple matches make a new contact
        mutableRecord = [[CNMutableContact alloc] init];
        newRecord = YES;
    } else {
        mutableRecord = [record mutableCopy];
    }
    
    if (contact.picture && (!mutableRecord.imageDataAvailable || [settings[@"pictures"] boolValue])) {
        if (contact.pictureData)
            mutableRecord.imageData = contact.pictureData;
        else {
            UIImage *picture = [[AsyncImageLoader defaultCache] objectForKey:[NSURL URLWithString:contact.picture]];
            if (picture)
                mutableRecord.imageData = UIImageJPEGRepresentation(picture, 0.01);
            else {
                NSData *image = UIImageJPEGRepresentation([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:contact.picture]]], 0.01);
                contact.pictureData = image;
                mutableRecord.imageData = UIImageJPEGRepresentation([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:contact.picture]]], 0.01);
            }
        
        }
    }
    
    if (newRecord || [settings[@"names"] boolValue]) {
        mutableRecord.givenName = contact.firstName;
        if (contact.lastName)
            mutableRecord.familyName = contact.lastName;
        else
            mutableRecord.familyName = @"";
    }
 
    if ([card.phones count] > 0) {
        NSMutableArray *phones = mutableRecord.phoneNumbers.mutableCopy;
        //ABMutableMultiValueRef phones = ABMultiValueCreateMutableCopy(ABRecordCopyValue(record, kABPersonPhoneProperty));//ABMultiValueCreateMutable(kABMultiStringPropertyType);
        // loop through phones
        for (Phone *phone in card.phones) {
            BOOL skip = NO;
            
            //CFIndex numPhones = ABMultiValueGetCount(phones);
            for (CNLabeledValue *value in phones) {
                NSString *number = ((CNPhoneNumber *)value.value).stringValue;
                number = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                if ([phone.number hasSuffix:number]) {
                    skip = YES; // number already exists in contact
                    break;
                }
            }
            
            if (skip) continue;
            
            NBPhoneNumberUtil *util = [[NBPhoneNumberUtil alloc] init];
            NBPhoneNumber *phoneNumber = [util parse:phone.number defaultRegion:phone.countryCode error:nil];
            
            CNPhoneNumber *pN = [[CNPhoneNumber alloc] initWithStringValue:[util format:phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:nil]];
            CNLabeledValue *value = [[CNLabeledValue alloc] initWithLabel:[phone.label lowercaseString] value:pN];
            
            [phones addObject:value];
            
            //ABMultiValueAddValueAndLabel(phones, (__bridge CFTypeRef)([util format:phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:nil]), type, NULL);
        }
        
        mutableRecord.phoneNumbers = phones;
        //ABRecordSetValue(record, kABPersonPhoneProperty, phones, &error);
        //CFRelease(phones);
    }
    
    if ([card.emails count] > 0) {
        NSMutableArray *emails = mutableRecord.emailAddresses.mutableCopy;
        // loop through emails
        for (Email *email in card.emails) {
            BOOL skip = NO;
            
            for (CNLabeledValue *emailAddress in emails) {
                NSString *address = emailAddress.value;
                if ([address isEqualToString:email.address]) {
                    skip = YES; // email already exists in contact
                    break;
                }
            }
            
            if (skip) continue;
            
            if ([email.address length] == 0) continue;
            
            CNLabeledValue *value = [[CNLabeledValue alloc] initWithLabel:[email.label lowercaseString] value:email.address];
            [emails addObject:value];
        }
        
        mutableRecord.emailAddresses = emails;
    }
    
    if ([card.addresses count] > 0) {
        NSMutableArray *addresses = mutableRecord.postalAddresses.mutableCopy;
        // loop through addresses
        for (Address *address in card.addresses) {
            BOOL skip = NO;
            
            for (CNLabeledValue *value in addresses) {
                CNPostalAddress *postalAddress = value.value;
                if (!address.street1 || [postalAddress.street containsString:address.street1]) {
                    skip = YES; // address already exists in contact
                    break;
                }
            }
            
            if (skip) continue;
            
            CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
            if ([address.street1 length] > 0 && [address.street2 length] > 0) postalAddress.street = [NSString stringWithFormat:@"%@\n%@", address.street1, address.street2];
            else if ([address.street1 length] > 0) postalAddress.street = address.street1;
            else if ([address.street2 length] > 0) postalAddress.street = address.street2;
            if ([address.city length] > 0) postalAddress.city = address.city;
            if ([address.state length] > 0) postalAddress.state = address.state;
            if ([address.zip length] > 0) postalAddress.postalCode = address.zip;
            
            CNLabeledValue *value = [[CNLabeledValue alloc] initWithLabel:[address.label lowercaseString] value:postalAddress];
            [addresses addObject:value];
        }
        
        mutableRecord.postalAddresses = addresses;
    }
    
    if ([card.socials count] > 0) {
        NSMutableArray *socials = [[NSMutableArray alloc] init];
        // loop through socials
        for (Social *social in card.socials) {
            if ([social.network length] == 0 || [social.username length] == 0 || [[social.network lowercaseString] isEqualToString:@"facebook"]) continue;
            NSString *type = [[social.network lowercaseString] capitalizedString];
            if ([[social.network uppercaseString] isEqualToString:@"TWITTER"]) type = CNSocialProfileServiceTwitter;
            else if ([[social.network uppercaseString] isEqualToString:@"FLICKR"]) type = CNSocialProfileServiceFlickr;
            else if ([[social.network uppercaseString] isEqualToString:@"GAME CENTER"] || [[social.network uppercaseString] isEqualToString:@"GAMECENTER"]) type = CNSocialProfileServiceGameCenter;
            else if ([[social.network uppercaseString] isEqualToString:@"LINKEDIN"]) type = CNSocialProfileServiceLinkedIn;
            else if ([[social.network uppercaseString] isEqualToString:@"MYSPACE"]) type = CNSocialProfileServiceMySpace;
            else
                continue;
            
            CNSocialProfile *socialProfile = [[CNSocialProfile alloc] initWithUrlString:nil username:social.username userIdentifier:nil service:type];
            CNLabeledValue *value = [[CNLabeledValue alloc] initWithLabel:type value:socialProfile];
            
            [socials addObject:value];
        }
        
        mutableRecord.socialProfiles = socials;
    }
    
    
    CNSaveRequest *request = [[CNSaveRequest alloc] init];
    
    if (newRecord) {
        [request addContact:mutableRecord toContainerWithIdentifier:nil];
    } else {
        [request updateContact:mutableRecord];
    }
    
    [contactStore executeSaveRequest:request error:&error];
    
    contact.saved = @(YES);
}

@end
