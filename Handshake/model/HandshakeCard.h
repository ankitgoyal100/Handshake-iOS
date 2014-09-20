//
//  Card.h
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandshakePhone.h"
#import "HandshakeEmail.h"
#import "HandshakeAddress.h"
#import "HandshakeSocial.h"

@interface HandshakeCard : NSObject

@property (nonatomic) long cardId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSMutableArray *phones;
@property (nonatomic, strong) NSMutableArray *emails;
@property (nonatomic, strong) NSMutableArray *addresses;
@property (nonatomic, strong) NSMutableArray *socials;

+ (HandshakeCard *)cardFromDictionary:(NSDictionary *)dict;
+ (NSDictionary *)dictionaryFromCard:(HandshakeCard *)card;

- (NSString *)formattedName;

- (HandshakeCard *)createCopy;
- (void)setToCard:(HandshakeCard *)card;

- (void)clean;

@end
