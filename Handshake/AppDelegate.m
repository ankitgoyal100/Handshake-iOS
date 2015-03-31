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
#import "CardPictureCache.h"
#import "StartViewController.h"
#import "MainViewController.h"
#import "HandshakeSession.h"

@interface AppDelegate ()

@property (nonatomic, strong) CardPictureCache *pictureCache;

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [SSKeychain setAccessibilityType:kSecAttrAccessibleAlways];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //[FBSession.activeSession closeAndClearTokenInformation];
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [[FacebookHelper sharedHelper] loginWithSuccessBlock:nil errorBlock:nil];
    }
    
    self.pictureCache = [[CardPictureCache alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([HandshakeSession restoreSession]) {
        MainViewController *controller = [[MainViewController alloc] initWithNibName:nil bundle:nil];
        self.window.rootViewController = controller;
    } else {
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[StartViewController alloc] initWithLoading:NO]];
        controller.navigationBarHidden = YES;
        self.window.rootViewController = controller;
    }

    [self.window makeKeyAndVisible];
    
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
