//
//  LocationUpdater.h
//  Handshake
//
//  Created by Sam Ober on 6/11/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LocationStatusNotAsked = 0,
    LocationStatusGranted,
    LocationStatusRevoked
} LocationStatus;

typedef void (^LocationRequestCompletionBlock)(BOOL success);

@interface LocationUpdater : NSObject

+ (LocationUpdater *)sharedUpdater;

- (LocationStatus)locationStatus;
- (void)requestLocationPermissionsWithCompletionBlock:(LocationRequestCompletionBlock)completionBlock;

- (void)updateLocation;

@end
