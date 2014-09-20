//
//  Social.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeSocial.h"

@implementation HandshakeSocial

- (id)initWithUsername:(NSString *)username network:(NSString *)network {
    self = [super init];
    if (self) {
        self.username = username;
        self.network = network;
    }
    return self;
}

@end
