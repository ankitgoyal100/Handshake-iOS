//
//  ContactUploader.h
//  Handshake
//
//  Created by Sam Ober on 6/15/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactUploader : NSObject

+ (void)upload;
+ (void)uploadWithCompletionBlock:(void (^)())completionBlock;

@end
