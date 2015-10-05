//
//  AppDelegate.m
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AppDelegate.h"
#import "HandshakeCoreDataStore.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookHelper.h"
#import "SSKeychain.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "UserPictureCache.h"
#import "StartViewController.h"
#import "MainViewController.h"
#import "HandshakeSession.h"
#import "LocationUpdater.h"
#import "NBPhoneNumberUtil.h"
#import "NotificationsHelper.h"
#import <AddressBook/AddressBook.h>
#import "FeedItemServerSync.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@property (nonatomic, strong) UserPictureCache *pictureCache;

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"0928683974cc9fd8cd69e6d66d535815"];
//    [[BITHockeyManager sharedHockeyManager] startManager];
//    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    [Fabric with:@[[Crashlytics class]]];
    
    // set navigation bar font
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[[UINavigationBar appearance] titleTextAttributes]];
    dict[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:dict];
    
    // set initial settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"auto_sync"]) {
        [defaults setObject:@{ @"enabled": @(YES), @"names": @(NO), @"pictures": @(NO) } forKey:@"auto_sync"];
        
        NBPhoneNumberUtil *util = [[NBPhoneNumberUtil alloc] init];
        [defaults setObject:[[util countryCodeByCarrier] uppercaseString] forKey:@"country_code"];
        
        [defaults setBool:(ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusNotDetermined) forKey:@"address_book_permissions"];
        [defaults setBool:([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) forKey:@"location_permissions"];
        [defaults setBool:[UIApplication sharedApplication].isRegisteredForRemoteNotifications forKey:@"notifications_permissions"];
        
        [defaults synchronize];
    }
    
    [SSKeychain setAccessibilityType:kSecAttrAccessibleAlways];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //[FBSession.activeSession closeAndClearTokenInformation];
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [[FacebookHelper sharedHelper] loginWithSuccessBlock:nil errorBlock:nil];
    }
    
    self.pictureCache = [[UserPictureCache alloc] init];
    
    // check for current session
    if ([HandshakeSession currentSession]) {
        // if app is not in background state run syncs
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
            [HandshakeSession sync];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateInitialViewController];
    }

    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSString *token = [[devToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NotificationsHelper sharedHelper] registerDevice:token];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    [[NotificationsHelper sharedHelper] registerFailed];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[NotificationsHelper sharedHelper] handleNotification:userInfo completionBlock:^{
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([HandshakeSession currentSession])
        [FeedItemServerSync sync];
    
    application.applicationIconBadgeNumber = 0;
    
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[HandshakeCoreDataStore defaultStore] saveMainContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end
