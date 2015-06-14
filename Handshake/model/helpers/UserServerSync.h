//
//  UserServerSync.h
//  Handshake
//
//  Created by Sam Ober on 6/14/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserServerSync : NSObject

+ (void)cacheUsers:(NSArray *)jsonArray completionBlock:(void (^)(NSArray *users))completionBlock;

@end
