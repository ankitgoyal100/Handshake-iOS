//
//  LocationManager.h
//  Handshake
//
//  Created by Sam Ober on 4/6/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject

+ (LocationManager *)sharedManager;

- (void)startUpdating;
- (void)stopUpdating;

@end
