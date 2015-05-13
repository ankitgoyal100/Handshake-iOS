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

@interface SearchResult : NSManagedObject

@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSNumber * mutual;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSData * pictureData;
@property (nonatomic, retain) Request *request;
@property (nonatomic, retain) Contact *contact;

- (NSString *)formattedName;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end
