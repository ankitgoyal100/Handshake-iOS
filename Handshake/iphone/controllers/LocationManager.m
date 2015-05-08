//
//  LocationManager.m
//  Handshake
//
//  Created by Sam Ober on 4/6/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "HandshakeSession.h"
#import "HandshakeClient.h"

@interface LocationManager() <CLLocationManagerDelegate>

@property (nonatomic, strong) NSDate *lastLocationUpdate;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocationManager *significantChangeManager;

@property (nonatomic, strong) CLCircularRegion *region;

@property (nonatomic) BOOL updating;

@end

@implementation LocationManager

+ (LocationManager *)sharedManager {
    static LocationManager *manager = nil;
    if (!manager)
        manager = [[LocationManager alloc] init];
    return manager;
}

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:[LocationManager sharedManager] selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[LocationManager sharedManager] selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[LocationManager sharedManager] selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (NSDate *)lastLocationUpdate {
    if (!_lastLocationUpdate) {
        _lastLocationUpdate = [NSDate dateWithTimeIntervalSinceNow:-1000000];
    }
    return _lastLocationUpdate;
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

- (CLLocationManager *)significantChangeManager {
    if (!_significantChangeManager) {
        _significantChangeManager = [[CLLocationManager alloc] init];
    }
    return _significantChangeManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.updating = NO;
        
        // create managers
        [self significantChangeManager];
    }
    return self;
}

- (void)startUpdating {
    if (self.updating)
        return;
    
    self.updating = YES;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdating {
    self.updating = NO;
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    
    NSTimeInterval timeSinceLastUpdate = fabs([self.lastLocationUpdate timeIntervalSinceNow]);
    if (timeSinceLastUpdate > 60) {
        if (location.horizontalAccuracy < 100) {
            if (self.locationManager.desiredAccuracy == kCLLocationAccuracyBest) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
                self.locationManager.distanceFilter = 5;
            }
            
            // post location update
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
            params[@"lat"] = [NSNumber numberWithDouble:location.coordinate.latitude];
            params[@"long"] = [NSNumber numberWithDouble:location.coordinate.longitude];
            
            [[HandshakeClient client] POST:@"/locations" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                // do nothing
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if ([[operation response] statusCode] == 401) {
                    // check if session is good (if so, invalidate it)
                    if ([HandshakeSession currentSession])
                        [[HandshakeSession currentSession] invalidate];
                    else {
                        // logged out stop location updates
                        [self.locationManager stopUpdatingLocation];
                    }
                }
            }];
            
            self.lastLocationUpdate = [NSDate date];
        } else if (self.locationManager.desiredAccuracy == kCLLocationAccuracyThreeKilometers) {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 5;
        }
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo allKeys] containsObject:UIApplicationLaunchOptionsLocationKey]) {
        [self startUpdating];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (self.updating) {
        [self.significantChangeManager requestAlwaysAuthorization];
        [self.significantChangeManager startMonitoringSignificantLocationChanges];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self.significantChangeManager stopMonitoringSignificantLocationChanges];
}

@end
