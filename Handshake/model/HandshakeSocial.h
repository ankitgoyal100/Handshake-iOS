//
//  Social.h
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandshakeSocial : NSObject

- (id)initWithUsername:(NSString *)username network:(NSString *)network;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *network;

@end
