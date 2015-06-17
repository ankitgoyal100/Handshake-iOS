//
//  Suggestion.h
//  Handshake
//
//  Created by Sam Ober on 6/15/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Suggestion : NSManagedObject

@property (nonatomic, retain) User *user;

@end
