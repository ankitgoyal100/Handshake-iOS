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
#import "SettingsViewController.h"
#import "StartViewController.h"
#import "HandshakeSession.h"
#import "UIControl+Blocks.h"
#import "HandshakeClient.h"
#import "HandshakeCoreDataStore.h"
#import "Card.h"
#import "UserViewController.h"
#import "LocationUpdater.h"
#import "SearchViewController.h"
#import "GroupCodeHelper.h"
#import "NotificationsHelper.h"

@interface MainViewController() <NotificationsHelperDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) JoinGroupDialogViewController *groupDialog;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    [NotificationsHelper sharedHelper].delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceLogout:) name:SESSION_INVALID object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:SESSION_ENDED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForGroupCode) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // setup view controllers
    
    UserViewController *userController = (UserViewController *)((UINavigationController *)self.viewControllers[3]).visibleViewController;
    userController.user = [[HandshakeSession currentSession] account];
    userController.title = @"Me";
    
    self.tabBar.tintColor = LOGO_COLOR;
    
    [[LocationUpdater sharedUpdater] updateLocation];
    
    // ask for notifications
    if ([[NotificationsHelper sharedHelper] notificationsStatus] == NotificationsStatusNotAsked) {
        // check notifications asked date (don't ask more than once a day)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDate *lastAsk = [defaults objectForKey:@"notifications_ask_date"];
        if (!lastAsk || [[NSDate date] timeIntervalSinceDate:lastAsk] > 60 * 60 * 24) {
            [defaults setObject:[NSDate date] forKey:@"notifications_ask_date"];
            [defaults synchronize];
            
            [[[UIAlertView alloc] initWithTitle:@"Allow Notifications?" message:@"Get alerted whenever someone sends you a request, adds you as a contact, or joins one of your groups!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Allow", nil] show];
        }
    } else if ([[NotificationsHelper sharedHelper] notificationsStatus] == NotificationsStatusGranted) {
        // post device token
        [[NotificationsHelper sharedHelper] requestNotificationsPermissionsWithCompletionBlock:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self checkForGroupCode];
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

- (void)checkForGroupCode {
    NSString *code = [GroupCodeHelper code];
    
    if (code) {
        // check in defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[defaults stringForKey:@"group_code"] isEqualToString:code]) return; // already presented dialog
        else {
            [defaults setObject:code forKey:@"group_code"];
            [defaults synchronize];
        }
        
        // check for local groups
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
        request.predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
        request.fetchLimit = 1;
        __block NSArray *results;
        [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
            results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:nil];
        }];
        
        if (results && [results count] == 1) return; // group already added
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Group" bundle:nil];
        
        self.groupDialog = [storyboard instantiateInitialViewController];
        self.groupDialog.groupCode = code;
        
        [self.view.window addSubview:self.groupDialog.view];
    }
}

- (void)openUser:(User *)user {
    UINavigationController *controller = (UINavigationController *)self.selectedViewController;
    
    UserViewController *userController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    userController.user = user;
    [controller pushViewController:userController animated:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Allow"]) {
        [[NotificationsHelper sharedHelper] requestNotificationsPermissionsWithCompletionBlock:nil];
    }
}

@end
