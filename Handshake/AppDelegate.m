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

@interface AppDelegate ()

@property (nonatomic, strong) UserPictureCache *pictureCache;

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // set navigation bar font
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[[UINavigationBar appearance] titleTextAttributes]];
    //dict[NSFontAttributeName] = [UIFont fontWithName:@"Roboto-Medium" size:17];
    dict[NSForegroundColorAttributeName] = [UIColor whiteColor];
    //dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
    //dict[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    [[UINavigationBar appearance] setTitleTextAttributes:dict];
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
//                                      forBarPosition:UIBarPositionAny
//                                          barMetrics:UIBarMetricsDefault];
//    
//    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
//    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
//    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    // set initial settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"auto_sync"]) {
        [defaults setObject:@{ @"enabled": @(YES), @"names": @(NO), @"pictures": @(NO) } forKey:@"auto_sync"];
        
        NBPhoneNumberUtil *util = [[NBPhoneNumberUtil alloc] init];
        [defaults setObject:[[util countryCodeByCarrier] uppercaseString] forKey:@"country_code"];
        
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateInitialViewController];
    }
    
    /*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([HandshakeSession currentSession]) {
        MainViewController *controller = [[MainViewController alloc] initWithNibName:nil bundle:nil];
        self.window.rootViewController = controller;
    } else {
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[StartViewController alloc] initWithLoading:NO]];
        controller.navigationBarHidden = YES;
        self.window.rootViewController = controller;
    }

    [self.window makeKeyAndVisible];
    */
    return YES;
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
