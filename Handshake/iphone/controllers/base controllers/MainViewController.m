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
#import "ShakeController.h"
#import "Contact.h"

@interface MainViewController()

@property (nonatomic, strong) ShakeController *shakeController;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Contact sync];
    [Card sync];

    // setup Contacts tab
    UINavigationController *contacts = [[UINavigationController alloc] initWithRootViewController:[[ContactsViewController alloc] initWithNibName:nil bundle:nil]];
    contacts.navigationBar.barTintColor = LOGO_COLOR;
    contacts.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor] };
    contacts.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Contacts" image:[UIImage imageNamed:@"contacts.png"] selectedImage:[UIImage imageNamed:@"contacts_selected.png"]];
    
    // setup Cards tab
    UINavigationController *cards = [[UINavigationController alloc] initWithRootViewController:[[CardsViewController alloc] initWithNibName:nil bundle:nil]];
    cards.navigationBar.barTintColor = LOGO_COLOR;
    cards.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor] };
    cards.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Cards" image:[UIImage imageNamed:@"cards.png"] selectedImage:[UIImage imageNamed:@"cards_selected.png"]];
    
    // setup Settings tab
    UINavigationController *settings = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] initWithNibName:nil bundle:nil]];
    settings.navigationBar.barTintColor = LOGO_COLOR;
    settings.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor] };
    settings.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"settings.png"] selectedImage:[UIImage imageNamed:@"settings_selected.png"]];
    
    self.viewControllers = @[contacts, cards, settings];
    
    self.tabBar.tintColor = LOGO_COLOR;
    
    self.shakeController = [[ShakeController alloc] init];
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

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) [self.shakeController shake];
}

@end
