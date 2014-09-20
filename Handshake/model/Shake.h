//
//  Shake.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Shake : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * shakeId;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Contact *contact;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end
