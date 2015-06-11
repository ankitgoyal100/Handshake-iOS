//
//  MainViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "MainViewController.h"
#import "ContactsViewController.h"
#import "Handshake.h"
#import "CardsViewController.h"
#import "SettingsViewController.h"
#import "StartViewController.h"
#import "HandshakeSession.h"
#import "UIControl+Blocks.h"
#import "HandshakeClient.h"
#import "HandshakeCoreDataStore.h"
#import "Card.h"
#import "Contact.h"
#import "UserViewController.h"
#import "LocationUpdater.h"
#import "SearchViewController.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceLogout:) name:SESSION_INVALID object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:SESSION_ENDED object:nil];
    
    // setup view controllers
    
    UserViewController *userController = (UserViewController *)((UINavigationController *)self.viewControllers[3]).visibleViewController;
    userController.user = [[HandshakeSession currentSession] account];
    userController.title = @"You";
    
    self.tabBar.tintColor = LOGO_COLOR;
    
    [[LocationUpdater sharedUpdater] updateLocation];
    
//    self.tabBar.layer.masksToBounds = NO;
//    self.tabBar.layer.shadowOffset = CGSizeMake(0, 1);
//    self.tabBar.layer.shadowOpacity = 0.3;
    
    
    
    //[[LocationManager sharedManager] startUpdating];
}

- (void)logout:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Start" bundle:nil];
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:[storyboard instantiateInitialViewController]];
}

- (void)forceLogout:(NSNotification *)notification {
    [self logout:notification];
    
    [[[UIAlertView alloc] initWithTitle:@"Not Logged In" message:@"You have been logged out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// override for search views
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]] && viewController == tabBarController.selectedViewController) {
        UINavigationController *nav = (UINavigationController *)viewController;
        
        if ([nav.visibleViewController isKindOfClass:[SearchViewController class]]) {
            [nav popToRootViewControllerAnimated:NO];
            return NO;
        }
    }
    
    return YES;
}

@end
