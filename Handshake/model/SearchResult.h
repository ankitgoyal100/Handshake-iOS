//
//  SearchResult.h
//  Handshake
//
//  Created by Sam Ober on 5/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Request;
@class Contact;
@class User;

@interface SearchResult : NSManagedObject

@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) Request *request;
@property (nonatomic, retain) Contact *contact;
@property (nonatomic, retain) User *user;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

+ (void)syncSuggestions;
+ (void)syncSuggestionsWithCompletionBlock:(void (^)())completionBlock;

@end
