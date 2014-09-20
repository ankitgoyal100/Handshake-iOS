//
//  Email.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeEmail.h"

@implementation HandshakeEmail

- (id)initWithAddress:(NSString *)address label:(NSString *)label {
    self = [super init];
    if (self) {
        self.address = address;
        self.label = label;
    }
    return self;
}

@end
