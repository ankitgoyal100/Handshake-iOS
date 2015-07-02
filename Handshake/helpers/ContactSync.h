//
//  ContactSync.h
//  Handshake
//
//  Created by Sam Ober on 6/10/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AddressBookStatusNotAsked = 0,
    AddressBookStatusGranted,
    AddressBookStatusRevoked
} AddressBookStatus;

@interface ContactSync : NSObject

+ (AddressBookStatus)addressBookStatus;
+ (void)requestAddressBookAccessWithCompletionBlock:(void (^)(BOOL success))completionBlock;

+ (void)sync;
+ (void)syncWithCompletionBlock:(void (^)())completionBlock;

+ (void)syncAll;

@end
