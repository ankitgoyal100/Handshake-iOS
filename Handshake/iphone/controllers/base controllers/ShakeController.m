//
//  ShakeController.m
//  Handshake
//
//  Created by Sam Ober on 10/5/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ShakeController.h"
#import "Card.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "UIControl+Blocks.h"
#import "Contact.h"
#import "NewContactViewController.h"

#define kFilteringFactor    0.1

int accelX = 0;
int accelY = 0;
int accelZ = 0;

@interface ShakeController() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic) BOOL shaking;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic) ShakeView *shakeView;

@property (nonatomic) int tries;

@end

@implementation ShakeController

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.locationManager.distanceFilter = 5;
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        
        self.shaking = NO;
        
        //[self startMotionDetection];
    }
    return self;
}

- (void)shake {
    if (self.shaking) return;
    
    self.shaking = YES;
    
    long long time = (long long)(CFAbsoluteTimeGetCurrent() * 1000) + 978307200000;
    
    // get current card
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Card"];
    request.predicate = [NSPredicate predicateWithFormat:@"cardOrder == 0 && user!=nil && syncStatus!= %@", [NSNumber numberWithInt:CardDeleted]];
    request.fetchLimit = 1;
    
    __block NSArray *results;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        NSError *error;
        results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:&error];
    }];
    
    if (!results) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not shake at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        self.shaking = NO;
        return;
    }
    
    if ([results count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"You Have No Cards" message:@"Please create a card before shaking." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        self.shaking = NO;
        return;
    }
    
    Card *card = results[0];
    
    UIView *base = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    self.shakeView = [[ShakeView alloc] initWithFrame:base.bounds];
    [base addSubview:self.shakeView];
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[HandshakeSession credentials]];
    params[@"time"] = [NSNumber numberWithLongLong:time];
    params[@"lat"] = [NSNumber numberWithDouble:self.latitude];
    params[@"long"] = [NSNumber numberWithDouble:self.longitude];
    params[@"card_id"] = card.cardId;
    [[HandshakeClient client] POST:@"/shakes" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (!self.shaking) return;
        
        __block long shakeId = [responseObject[@"shake"][@"id"] longValue];
        
        [self checkShakeWithId:shakeId];
        
        [self.shakeView.confirmButton addEventHandler:^(id sender) {
            [[HandshakeClient client] GET:[NSString stringWithFormat:@"/shakes/%ld/confirm", shakeId] parameters:[HandshakeSession credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                weakSelf.shakeView.shakeStatus = ShakeWaitingConfirmationStatus;
                [weakSelf addContactWithShakeId:shakeId start:[NSDate date]];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [weakSelf.shakeView removeFromSuperview];
                weakSelf.shaking = NO;
                if ([[operation response] statusCode] == 401) {
                    [HandshakeSession invalidate];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        } forControlEvents:UIControlEventTouchUpInside];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.shaking) return;
        
        [self.shakeView removeFromSuperview];
        self.shaking = NO;
        if ([[operation response] statusCode] == 401) {
            [HandshakeSession invalidate];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not shake at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
    
    [self.shakeView.cancelButton addEventHandler:^(id sender) {
        [weakSelf.shakeView removeFromSuperview];
        weakSelf.shaking = NO;
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.shakeView.stopShakeButton addEventHandler:^(id sender) {
        [weakSelf.shakeView removeFromSuperview];
        weakSelf.shaking = NO;
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)checkShakeWithId:(long)shakeId {
    if (!self.shaking) return;
    
    [[HandshakeClient client] GET:[NSString stringWithFormat:@"/shakes/%ld/check", shakeId] parameters:[HandshakeSession credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (!self.shaking) return;
        
        NSDictionary *preview = [HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"preview"]];
        if (preview[@"first_name"] && preview[@"last_name"])
            [self.shakeView setName:[NSString stringWithFormat:@"%@ %@", preview[@"first_name"], preview[@"last_name"]]];
        else if (preview[@"first_name"])
            [self.shakeView setName:preview[@"first_name"]];
        else
            [self.shakeView setName:preview[@"last_name"]];
        
        [self.shakeView setPicture:preview[@"picture"]];
        
        self.shakeView.shakeStatus = ShakeConfirmingStatus;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.shaking) return;
        
        if ([[operation response] statusCode] == 404) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self checkShakeWithId:shakeId];
            });
        } else {
            [self.shakeView removeFromSuperview];
            self.shaking = NO;
            if ([[operation response] statusCode] == 401) {
                [HandshakeSession invalidate];
            } else if ([[operation response] statusCode] == 401 || [[operation response] statusCode] == 410) {
                [[[UIAlertView alloc] initWithTitle:@"Timed Out" message:@"Could not find a match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
}

- (void)addContactWithShakeId:(long)shakeId start:(NSDate *)start {
    if ([[NSDate date] timeIntervalSince1970] - [start timeIntervalSince1970] > 5) {
        [self.shakeView removeFromSuperview];
        self.shaking = NO;
        [[[UIAlertView alloc] initWithTitle:@"Timed Out" message:@"Error confirming with other person." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [[HandshakeClient client] GET:[NSString stringWithFormat:@"/shakes/%ld/add", shakeId] parameters:[HandshakeSession credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
        Contact *contact = [[Contact alloc] initWithEntity:entity insertIntoManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
        
        [contact updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"contact"]]];
        contact.syncStatus = [NSNumber numberWithInt:ContactSynced];
        
        [[HandshakeCoreDataStore defaultStore] saveMainContext];
        
        [self.shakeView removeFromSuperview];
        self.shaking = NO;
        
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[NewContactViewController alloc] initWithContact:contact]];
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [topController presentViewController:controller animated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 409) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self addContactWithShakeId:shakeId start:start];
            });
        } else {
            [self.shakeView removeFromSuperview];
            self.shaking = NO;
            if ([[operation response] statusCode] == 401) {
                [HandshakeSession invalidate];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
}

- (void)startMotionDetection {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.05;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            if (self.shaking) return;
            
            CMAcceleration acceleration = accelerometerData.acceleration;
            float prevAccelX = accelX;
            float prevAccelY = accelY;
            float prevAccelZ = accelZ;
            accelX = acceleration.x - ( (acceleration.x * kFilteringFactor) +
                                       (accelX * (1.0 - kFilteringFactor)) );
            accelY = acceleration.y - ( (acceleration.y * kFilteringFactor) +
                                       (accelY * (1.0 - kFilteringFactor)) );
            accelZ = acceleration.z - ( (acceleration.z * kFilteringFactor) +
                                       (accelZ * (1.0 - kFilteringFactor)) );
            
            // Compute the derivative (which represents change in acceleration).
            float deltaX = ABS((accelX - prevAccelX));
            float deltaY = ABS((accelY - prevAccelY));
            float deltaZ = ABS((accelZ - prevAccelZ));
            
            // Check if the derivative exceeds some sensitivity threshold
            // (Bigger value indicates stronger bump)
            // (Probably should use length of the vector instead of componentwise)
            float strength = sqrtf(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
            if ( strength > 1 ) {
                accelX = accelY = accelZ = 0;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shake];
                });
            }
        }];
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation *location = [locations lastObject];
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        self.latitude = location.coordinate.latitude;
        self.longitude = location.coordinate.longitude;
    }
}

@end
