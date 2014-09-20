//
//  Social.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface Social : NSManagedObject

@property (nonatomic, retain) NSString * network;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) Card *card;

@end
