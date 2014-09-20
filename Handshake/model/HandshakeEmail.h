//
//  Email.h
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandshakeEmail : NSObject

- (id)initWithAddress:(NSString *)address label:(NSString *)label;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *label;

@end
