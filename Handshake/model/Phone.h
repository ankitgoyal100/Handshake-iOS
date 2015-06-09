//
//  Phone.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface Phone : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) Card *card;

@end
