//
//  FeedItemServerSync.h
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

@interface FeedItemServerSync : NSObject

+ (void)sync;
+ (void)syncWithCompletionBlock:(void (^)())completionBlock;

@end
