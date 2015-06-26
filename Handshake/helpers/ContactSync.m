//
//  ContactSync.m
//  Handshake
//
//  Created by Sam Ober on 6/10/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "ContactSync.h"
#import "HandshakeCoreDataStore.h"
#import <AddressBook/AddressBook.h>
#import "Card.h"
#import "User.h"
#import "Phone.h"
#import "Email.h"
#import "Address.h"
#import "Social.h"
#import "AsyncImageView.h"
#import "NBPhoneNumberUtil.h"

@implementation ContactSync

+ (AddressBookStatus)addressBookStatus {
    BOOL asked = [[NSUserDefaults standardUserDefaults] boolForKey:@"address_book_permissions"];
    BOOL granted = ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized;
    
    if (!asked) return AddressBookStatusNotAsked;
    if (asked && granted) return AddressBookStatusGranted;
    return AddressBookStatusRevoked;
}

+ (void)requestAddressBookAccessWithCompletionBlock:(void (^)(BOOL))completionBlock {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        if (completionBlock) completionBlock(YES);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"address_book_permissions"];
        [defaults synchronize];
        
        CFErrorRef error = NULL;
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, &error), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted && completionBlock)
                    completionBlock(YES);
                else if (completionBlock)
                    completionBlock(NO);
            });
        });
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
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto_sync"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
        
        if (!results) return; // something went wrong
        
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (!addressBook || ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) return;
        
        for (User *contact in results)
            [self syncContact:contact toAddressBook:addressBook];
        
        error = NULL;
        ABAddressBookSave(addressBook, &error);
        
        if (!error) {
            // save
            [objectContext performBlockAndWait:^{
                [objectContext save:nil];
            }];
            [[HandshakeCoreDataStore defaultStore] saveMainContext];
        }
    });
}

+ (void)syncContact:(User *)contact toAddressBook:(ABAddressBookRef)addressBook {
    if ([contact.cards count] == 0) return;
    
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto_sync"];
    
    Card *card = contact.cards[0];
    
    NSArray *records = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSInteger count = [records count];
    
    // find record to update
    
    ABRecordRef record = NULL;
    int matches = 0; // count of how many contacts have matching data
    
    for (int i = 0; i < count; i++) {
        ABRecordRef r = (__bridge ABRecordRef)records[i];
        int certainty = 0; // count of how many data points match
        BOOL nameMatch = NO;
        
        // check name
        NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(r);
        if ([name containsString:contact.firstName]) {
            nameMatch = YES;
            certainty++;
        }
        
        // check phones
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(r, kABPersonPhoneProperty);
        CFIndex numPhones = ABMultiValueGetCount(phoneNumbers);
        
        for (CFIndex index = 0; index < numPhones; index++) {
            NSString *number = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, index));
            number = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            
            for (Phone *phone in card.phones) {
                if ([phone.number hasSuffix:number]) {
                    // match
                    certainty++;
                    break;
                }
            }
        }
        
        CFRelease(phoneNumbers);
        
        // check emails
        
        ABMultiValueRef emailAddresses = ABRecordCopyValue(r, kABPersonEmailProperty);
        CFIndex numEmails = ABMultiValueGetCount(emailAddresses);
        
        for (CFIndex index = 0; index < numEmails; index++) {
            NSString *address = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emailAddresses, index));
            
            for (Email *email in card.emails) {
                if ([address isEqualToString:email.address]) {
                    // match
                    certainty++;
                    break;
                }
            }
        }
        
        CFRelease(emailAddresses);
        
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
    
    CFErrorRef error = NULL;
    BOOL newRecord = NO;
    
    if (!record || matches != 1) { // if no record found or multiple matches make a new contact
        record = ABPersonCreate();
        ABAddressBookAddRecord(addressBook, record, &error);
        newRecord = YES;
    }
    
    if (contact.picture && (!ABPersonHasImageData(record) || [settings[@"pictures"] boolValue])) {
        if (contact.pictureData)
            ABPersonSetImageData(record, (__bridge CFDataRef)(contact.pictureData), &error);
        else {
            UIImage *picture = [[AsyncImageLoader defaultCache] objectForKey:[NSURL URLWithString:contact.picture]];
            if (picture)
                ABPersonSetImageData(record, (__bridge CFDataRef)(UIImageJPEGRepresentation(picture, 0.01)), &error);
            else {
                NSData *image = UIImageJPEGRepresentation([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:contact.picture]]], 0.01);
                contact.pictureData = image;
                ABPersonSetImageData(record, (__bridge CFDataRef)(UIImageJPEGRepresentation([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:contact.picture]]], 0.01)), &error);
            }
        
        }
    }
    
    if (newRecord || [settings[@"names"] boolValue]) {
        ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)(contact.firstName), &error);
        if (contact.lastName)
            ABRecordSetValue(record, kABPersonLastNameProperty, (__bridge CFTypeRef)(contact.lastName), &error);
        else
            ABRecordSetValue(record, kABPersonLastNameProperty, (__bridge CFTypeRef)(@""), &error);
    }
    
    if ([card.phones count] > 0) {
        ABMutableMultiValueRef phones = ABMultiValueCreateMutableCopy(ABRecordCopyValue(record, kABPersonPhoneProperty));//ABMultiValueCreateMutable(kABMultiStringPropertyType);
        // loop through phones
        for (Phone *phone in card.phones) {
            BOOL skip = NO;
            
            CFIndex numPhones = ABMultiValueGetCount(phones);
            for (CFIndex index = 0; index < numPhones; index++) {
                NSString *number = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, index));
                number = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                if ([phone.number hasSuffix:number]) {
                    skip = YES; // number already exists in contact
                    break;
                }
            }
            
            if (skip) continue;
            
            CFStringRef type = (__bridge CFStringRef)(phone.label);
            if ([[phone.label lowercaseString] isEqualToString:@"home"]) type = kABHomeLabel;
            else if ([[phone.label lowercaseString] isEqualToString:@"cell"] || [[phone.label lowercaseString] isEqualToString:@"mobile"]) type = kABPersonPhoneMobileLabel;
            else if ([[phone.label lowercaseString] isEqualToString:@"work"] || [[phone.label lowercaseString] isEqualToString:@"office"]) type = kABWorkLabel;
            else type = kABOtherLabel;
            
            NBPhoneNumberUtil *util = [[NBPhoneNumberUtil alloc] init];
            NBPhoneNumber *phoneNumber = [util parse:phone.number defaultRegion:phone.countryCode error:nil];
            
            ABMultiValueAddValueAndLabel(phones, (__bridge CFTypeRef)([util format:phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:nil]), type, NULL);
        }
        ABRecordSetValue(record, kABPersonPhoneProperty, phones, &error);
        CFRelease(phones);
    }
    
    if ([card.emails count] > 0) {
        ABMutableMultiValueRef emails = ABMultiValueCreateMutableCopy(ABRecordCopyValue(record, kABPersonEmailProperty));//ABMultiValueCreateMutable(kABMultiStringPropertyType);
        // loop through emails
        for (Email *email in card.emails) {
            BOOL skip = NO;
            
            CFIndex numEmails = ABMultiValueGetCount(emails);
            for (CFIndex index = 0; index < numEmails; index++) {
                NSString *address = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, index));
                if ([address isEqualToString:email.address]) {
                    skip = YES; // email already exists in contact
                    break;
                }
            }
            
            if (skip) continue;
            
            if ([email.address length] == 0) continue;
            CFStringRef type = (__bridge CFStringRef)(email.label);
            if ([[email.label lowercaseString] isEqualToString:@"home"]) type = kABHomeLabel;
            else if ([[email.label lowercaseString] isEqualToString:@"work"] || [[email.label lowercaseString] isEqualToString:@"office"]) type = kABWorkLabel;
            else type = kABOtherLabel;
            ABMultiValueAddValueAndLabel(emails, (__bridge CFTypeRef)(email.address), type, NULL);
        }
        ABRecordSetValue(record, kABPersonEmailProperty, emails, &error);
        CFRelease(emails);
    }
    
    if ([card.addresses count] > 0) {
        ABMutableMultiValueRef addresses = ABMultiValueCreateMutableCopy(ABRecordCopyValue(record, kABPersonAddressProperty));//ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        // loop through addresses
        for (Address *address in card.addresses) {
            BOOL skip = NO;
            
            CFIndex numAddresses = ABMultiValueGetCount(addresses);
            for (CFIndex index = 0; index < numAddresses; index++) {
                NSDictionary *addressDict = CFBridgingRelease(ABMultiValueCopyValueAtIndex(addresses, index));
                if ([addressDict[(NSString *)kABPersonAddressStreetKey] containsString:address.street1]) {
                    skip = YES; // address already exists in contact
                    break;
                }
            }
            
            if (skip) continue;
            
            CFStringRef type = (__bridge CFStringRef)(address.label);
            if ([[address.label lowercaseString] isEqualToString:@"home"]) type = kABHomeLabel;
            else if ([[address.label lowercaseString] isEqualToString:@"work"] || [[address.label lowercaseString] isEqualToString:@"office"]) type = kABWorkLabel;
            else type = kABOtherLabel;
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            if ([address.street1 length] > 0 && [address.street2 length] > 0) [dict setObject:[NSString stringWithFormat:@"%@\n%@", address.street1, address.street2] forKey:(NSString *)kABPersonAddressStreetKey];
            else if ([address.street1 length] > 0) [dict setObject:address.street1 forKey:(NSString *)kABPersonAddressStreetKey];
            else if ([address.street2 length] > 0) [dict setObject:address.street2 forKey:(NSString *)kABPersonAddressStreetKey];
            if ([address.city length] > 0) [dict setObject:address.city forKey:(NSString *)kABPersonAddressCityKey];
            if ([address.state length] > 0) [dict setObject:address.state forKey:(NSString *)kABPersonAddressStateKey];
            if ([address.zip length] > 0) [dict setObject:address.zip forKey:(NSString *)kABPersonAddressZIPKey];
            //if ([address.country length] > 0) [dict setObject:address.country forKey:(NSString *)kABPersonAddressCountryKey];
            
            ABMultiValueAddValueAndLabel(addresses, (__bridge CFTypeRef)(dict), type, NULL);
        }
        ABRecordSetValue(record, kABPersonAddressProperty, addresses, &error);
        CFRelease(addresses);
    }
    
    if ([card.socials count] > 0) {
        ABMutableMultiValueRef socials = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        // loop through socials
        for (Social *social in card.socials) {
            if ([social.network length] == 0 || [social.username length] == 0 || [[social.network lowercaseString] isEqualToString:@"facebook"]) continue;
            CFStringRef type = (__bridge CFStringRef)([[social.network lowercaseString] capitalizedString]);
            if ([[social.network uppercaseString] isEqualToString:@"TWITTER"]) type = kABPersonSocialProfileServiceTwitter;
            else if ([[social.network uppercaseString] isEqualToString:@"FLICKR"]) type = kABPersonSocialProfileServiceFlickr;
            else if ([[social.network uppercaseString] isEqualToString:@"GAME CENTER"] || [[social.network uppercaseString] isEqualToString:@"GAMECENTER"]) type = kABPersonSocialProfileServiceGameCenter;
            else if ([[social.network uppercaseString] isEqualToString:@"LINKEDIN"]) type = kABPersonSocialProfileServiceLinkedIn;
            else if ([[social.network uppercaseString] isEqualToString:@"MYSPACE"]) type = kABPersonSocialProfileServiceMyspace;
            else
                continue;
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:social.username forKey:(NSString *)kABPersonSocialProfileUsernameKey];
            [dict setObject:(__bridge id)(type) forKey:(NSString *)kABPersonSocialProfileServiceKey];
            
            ABMultiValueAddValueAndLabel(socials, (__bridge CFTypeRef)(dict), type, NULL);
        }
        ABRecordSetValue(record, kABPersonSocialProfileProperty, socials, &error);
        CFRelease(socials);
    }
    
    contact.saved = @(YES);
}

@end
