//
//  Request.h
//  Handshake
//
//  Created by Sam Ober on 5/10/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Contact.h"

@class User;

@interface Request : NSManagedObject

@property (nonatomic, retain) NSNumber * requestId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * mutual;
@property (nonatomic, retain) User *user;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

+ (void)sync;
+ (void)syncWithCompletionBlock:(void (^)())completionBlock;

- (void)acceptWithSuccessBlock:(void (^)(Contact *))successBlock failedBlock:(void (^)())failedBlock;
- (void)deleteWithSuccessBlock:(void (^)())successBlock failedBlock:(void (^)())failedBlock;

@end
