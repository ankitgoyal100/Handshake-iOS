//
//  ContactUploader.m
//  Handshake
//
//  Created by Sam Ober on 6/15/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "ContactUploader.h"
#import <AddressBook/AddressBook.h>
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "NBPhoneNumberUtil.h"

@implementation ContactUploader

+ (void)upload {
    [self uploadWithCompletionBlock:nil];
}

+ (void)uploadWithCompletionBlock:(void (^)())completionBlock {
    // only upload in 7 day intervals
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpload = [defaults objectForKey:@"last_contact_upload"];
    if (lastUpload && [[NSDate date] timeIntervalSinceDate:lastUpload] < 3600 * 24 * 7) {
        if (completionBlock) completionBlock();
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (!addressBook || ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) return;
        
        NSArray *records = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
        NSInteger count = [records count];
        
        NSMutableArray *phones = [[NSMutableArray alloc] init];
        NSMutableArray *emails = [[NSMutableArray alloc] init];
        
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        
        // character set for trimming phone numbers
        NSMutableCharacterSet *set = [[[NSCharacterSet decimalDigitCharacterSet] invertedSet] mutableCopy];
        [set removeCharactersInString:@"+"];
        
        for (int i = 0; i < count; i++) {
            ABRecordRef r = (__bridge ABRecordRef)records[i];
            
            // get phones
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(r, kABPersonPhoneProperty);
            CFIndex numPhones = ABMultiValueGetCount(phoneNumbers);
            
            for (CFIndex index = 0; index < numPhones; index++) {
                NSString *number = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, index));
                number = [[number componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
                
                NBPhoneNumber *phoneNumber = [phoneUtil parseWithPhoneCarrierRegion:number error:nil];
                
                if (phoneNumber && [phoneUtil isValidNumber:phoneNumber])
                    [phones addObject:[phoneUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil]];
                else if (![number hasPrefix:@"+"]) {
                    // try to add + and check again (might be ill formatted international number)
                    
                    phoneNumber = [phoneUtil parseWithPhoneCarrierRegion:[NSString stringWithFormat:@"+%@", number] error:nil];
                    
                    if (phoneNumber && [phoneUtil isValidNumber:phoneNumber])
                        [phones addObject:[phoneUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil]];
                }
            }
            
            // get emails
            
            ABMultiValueRef emailAddresses = ABRecordCopyValue(r, kABPersonEmailProperty);
            CFIndex numEmails = ABMultiValueGetCount(emailAddresses);
            
            for (CFIndex index = 0; index < numEmails; index++) {
                NSString *address = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emailAddresses, index));
                
                [emails addObject:address];
            }
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
        params[@"phones"] = phones;
        [[HandshakeClient client] POST:@"/upload/phones" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [params removeObjectForKey:@"phones"];
            params[@"emails"] = emails;
            
            [[HandshakeClient client] POST:@"/upload/emails" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSDate date] forKey:@"last_contact_upload"];
                [defaults synchronize];
                
                if (completionBlock) completionBlock();
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if ([[operation response] statusCode] == 401)
                    [[HandshakeSession currentSession] invalidate];
                if (completionBlock) completionBlock();
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[operation response] statusCode] == 401)
                [[HandshakeSession currentSession] invalidate];
            if (completionBlock) completionBlock();
        }];
    });
}

@end
