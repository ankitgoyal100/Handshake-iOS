//
//  User.h
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandshakeUser : NSObject

@property (nonatomic) long userId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDate *confirmedAt;
@property (nonatomic, strong) NSString *unconfirmedEmail;
@property (nonatomic, strong) NSDate *confirmationSentAt;

+ (HandshakeUser *)userFromDictionary:(NSDictionary *)dict;

@end
