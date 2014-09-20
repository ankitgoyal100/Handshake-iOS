//
//  HandshakeClient.m
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeClient.h"

@implementation HandshakeClient

+ (AFHTTPRequestOperationManager *)client {
    static AFHTTPRequestOperationManager *client = nil;
    if (!client) {
        client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost:3000/"]];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return client;
}

@end
