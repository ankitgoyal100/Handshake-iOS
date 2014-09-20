//
//  Phone.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakePhone.h"

@implementation HandshakePhone

- (id)initWithNumber:(NSString *)number label:(NSString *)label {
    self = [super init];
    if (self) {
        self.number = number;
        self.label = label;
    }
    return self;
}

@end
