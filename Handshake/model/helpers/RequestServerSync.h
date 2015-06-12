//
//  RequestSync.h
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface RequestServerSync : NSObject

+ (void)sync;
+ (void)syncWithCompletionBlock:(void (^)())completionBlock;

+ (void)sendRequest:(User *)user successBlock:(void (^)(User *))successBlock failedBlock:(void (^)())failedBlock;
+ (void)deleteRequest:(User *)user successBlock:(void (^)(User *))successBlock failedBlock:(void (^)())failedBlock;

+ (void)acceptRequest:(User *)user successBlock:(void (^)(User *))successBlock failedBlock:(void (^)())failedBlock;
+ (void)declineRequest:(User *)user successBlock:(void (^)(User *))successBlock failedBlock:(void (^)())failedBlock;

@end
