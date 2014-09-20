//
//  HandshakeClient.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface HandshakeClient : NSObject

+ (AFHTTPRequestOperationManager *)client;

@end
