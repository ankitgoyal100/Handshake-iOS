//
//  Phone.h
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandshakePhone : NSObject

- (id)initWithNumber:(NSString *)number label:(NSString *)label;

@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *label;

@end
