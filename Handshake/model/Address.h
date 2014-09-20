//
//  Address.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * street1;
@property (nonatomic, retain) NSString * street2;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSManagedObject *card;

- (NSString *)formattedString;

@end
