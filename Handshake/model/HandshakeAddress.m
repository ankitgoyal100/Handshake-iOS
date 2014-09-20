//
//  Address.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeAddress.h"

@implementation HandshakeAddress

- (id)initWithStreet1:(NSString *)street1 street2:(NSString *)street2 city:(NSString *)city state:(NSString *)state zip:(NSString *)zip label:(NSString *)label {
    self = [super init];
    if (self) {
        self.street1 = street1;
        self.street2 = street2;
        self.city = city;
        self.state = state;
        self.zip = zip;
        self.label = label;
    }
    return self;
}

- (NSString *)formattedString {
    NSMutableString *formatted = [[NSMutableString alloc] init];
    
    if (self.street1 && self.street1.length != 0) [formatted appendString:self.street1];
    
    if (self.street2.length != 0) {
        if ([formatted length] > 0) [formatted appendString:@"\n"];
        [formatted appendString:self.street2];
    }
    
    if (self.city.length != 0) {
        if ([formatted length] > 0) [formatted appendString:@"\n"];
        [formatted appendString:self.city];
    }
    
    if (self.state.length != 0) {
        if (self.city.length != 0) [formatted appendString:@", "];
        else if ([formatted length] > 0) [formatted appendString:@"\n"];
        [formatted appendString:self.state];
    }
    
    if (self.zip.length != 0) {
        if (self.state.length != 0 || self.city.length != 0) [formatted appendString:@" "];
        else if ([formatted length] > 0) [formatted appendString:@"\n"];
        [formatted appendString:self.zip];
    }
    
    return formatted;
}

@end
