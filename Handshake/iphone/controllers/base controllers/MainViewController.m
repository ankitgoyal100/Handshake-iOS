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
#import "LocationManager.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup view controllers
    
    UserViewController *userController = (UserViewController *)((UINavigationController *)self.viewControllers[3]).visibleViewController;
    userController.user = [[HandshakeSession currentSession] account];
    userController.title = @"You";
    
    self.tabBar.tintColor = LOGO_COLOR;
    
//    self.tabBar.layer.masksToBounds = NO;
//    self.tabBar.layer.shadowOffset = CGSizeMake(0, 1);
//    self.tabBar.layer.shadowOpacity = 0.3;
    
    
    
    //[[LocationManager sharedManager] startUpdating];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceLogout:) name:SESSION_INVALID object:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SESSION_INVALID object:nil];
}

- (void)forceLogout:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SESSION_INVALID object:nil];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[StartViewController alloc] initWithNibName:nil bundle:nil]];
    controller.navigationBarHidden = YES;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:controller animated:YES completion:nil];
    
    if ([notification.object[@"confirmation_error"] boolValue])
        [[[UIAlertView alloc] initWithTitle:@"Confirmation Required" message:[NSString stringWithFormat:@"You need to confirm your account before you can login. Please check %@ for a confirmation message.", notification.object[@"email"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    else
        [[[UIAlertView alloc] initWithTitle:@"Not Logged In" message:@"You have been logged out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
