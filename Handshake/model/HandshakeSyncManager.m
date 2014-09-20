//
//  HandshakeSyncManager.m
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeSyncManager.h"

@interface HandshakeSyncManager()

@property (atomic) BOOL syncing;

@end

@implementation HandshakeSyncManager

+ (HandshakeSyncManager *)defaultManager {
    static HandshakeSyncManager *defaultManager = nil;
    if (!defaultManager) defaultManager = [[HandshakeSyncManager alloc] init];
    return defaultManager;
}

+ (void)sync {
    if (![self defaultManager].syncing) {
        [self defaultManager].syncing = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
        });
    }
}

- (void)syncContacts {
    
}

@end
