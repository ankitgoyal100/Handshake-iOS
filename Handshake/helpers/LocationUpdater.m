//
//  LocationUpdater.m
//  Handshake
//
//  Created by Sam Ober on 6/11/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "LocationUpdater.h"
#import <CoreLocation/CoreLocation.h>
#import "HandshakeSession.h"
#import "HandshakeClient.h"

@interface LocationUpdater() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) LocationRequestCompletionBlock completionBlock;

@end

@implementation LocationUpdater

+ (LocationUpdater *)sharedUpdater {
    static LocationUpdater *manager = nil;
    if (!manager)
        manager = [[LocationUpdater alloc] init];
    return manager;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    return _locationManager;
}

- (LocationStatus)locationStatus {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"location_permissions"]) return LocationStatusNotAsked;
    
    BOOL locationEnabled = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    if (locationEnabled) return LocationStatusGranted;
    return LocationStatusRevoked;
}

- (void)requestLocationPermissionsWithCompletionBlock:(LocationRequestCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"location_permissions"];
    [defaults synchronize];
    
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)updateLocation {
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *loc = [locations lastObject];
    
    if (loc.horizontalAccuracy <= 500) { // 500m is accurate enough
        [self.locationManager stopUpdatingLocation];
        
        // post location
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
        params[@"lat"] = @(loc.coordinate.latitude);
        params[@"lng"] = @(loc.coordinate.longitude);
        [[HandshakeClient client] POST:@"/account/location" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[operation response] statusCode] == 401)
                [[HandshakeSession currentSession] invalidate];
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (self.completionBlock) {
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse) self.completionBlock(YES);
        if (status == kCLAuthorizationStatusDenied) self.completionBlock(NO);
        self.completionBlock = nil;
    }
}

@end
