//
//  Address.m
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Address.h"


@implementation Address

@dynamic city;
@dynamic label;
@dynamic state;
@dynamic street1;
@dynamic street2;
@dynamic zip;
@dynamic card;

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
