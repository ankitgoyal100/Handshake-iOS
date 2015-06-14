//
//  CardServerSync.h
//  Handshake
//
//  Created by Sam Ober on 6/13/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardServerSync : NSObject

+ (void)sync;
+ (void)syncWithCompletionBlock:(void (^)())completionBlock;

@end
