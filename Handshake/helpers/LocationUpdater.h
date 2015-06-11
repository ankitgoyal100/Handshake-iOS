//
//  LocationUpdater.h
//  Handshake
//
//  Created by Sam Ober on 6/11/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationUpdater : NSObject

+ (LocationUpdater *)sharedUpdater;

- (void)updateLocation;

@end
