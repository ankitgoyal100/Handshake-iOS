//
//  GroupServerSync.h
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@interface GroupServerSync : NSObject

+ (void)sync;
+ (void)syncWithCompletionBlock:(void (^)())completionBlock;

+ (void)cacheGroups:(NSArray *)jsonArray completionsBlock:(void (^)(NSArray *groups))completionBlock;
+ (void)loadGroupMembers:(Group *)group completionBlock:(void (^)())completionBlock;

+ (void)deleteGroup:(Group *)group;

@end
