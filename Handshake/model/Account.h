//
//  Account.h
//  Handshake
//
//  Created by Sam Ober on 4/1/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"

typedef enum {
    AccountSynced = 0,
    AccountUpdated
} AccountSyncStatus;

@interface Account : User

@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSString * email;

+ (void)sync;
+ (void)syncWithSuccessBlock:(void (^)())successBlock;

@end
