//
//  ContactSyncSettingsViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/10/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "ContactSyncSettingsViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "ContactSync.h"

@interface ContactSyncSettingsViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *autoSyncSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *namesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *picturesSwitch;

@property (nonatomic, strong) NSMutableDictionary *settings;

@property (nonatomic) BOOL changed;

@end

@implementation ContactSyncSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"AutoSync";
    self.changed = NO;
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    self.settings = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"auto_sync"]];
    if (![self.settings[@"enabled"] boolValue] || [ContactSync addressBookStatus] != AddressBookStatusGranted) {
        self.autoSyncSwitch.on = NO;
        self.namesSwitch.enabled = NO;
        self.picturesSwitch.enabled = NO;
    }
    
    if (![self.settings[@"names"] boolValue])
        self.namesSwitch.on = NO;
    
    if (![self.settings[@"pictures"] boolValue])
        self.picturesSwitch.on = NO;
}

- (void)back {
    [[NSUserDefaults standardUserDefaults] setObject:self.settings forKey:@"auto_sync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.changed) [ContactSync syncAll];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)autoSwitchChanged:(id)sender {
    // check if permissions are correct
    if ([ContactSync addressBookStatus] != AddressBookStatusGranted) {
        [self.autoSyncSwitch setOn:NO animated:YES];
        if ([ContactSync addressBookStatus] == AddressBookStatusRevoked) {
            // send user to settings
            [[[UIAlertView alloc] initWithTitle:@"Turn on address book permissions." message:@"Please enable it in 'Settings' -> 'Privacy' -> 'Contacts'" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else if ([ContactSync addressBookStatus] == AddressBookStatusNotAsked) {
            // request address book permissions
            [[[UIAlertView alloc] initWithTitle:@"Allow Handshake to access contacts?" message:@"Handshake needs access to your address book in order to run AutoSync." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Allow", nil] show];
        }
        return;
    }
    
    self.changed = YES;
    if (self.autoSyncSwitch.on) {
        self.settings[@"enabled"] = @(YES);
        self.namesSwitch.enabled = YES;
        self.picturesSwitch.enabled = YES;
    } else {
        self.settings[@"enabled"] = @(NO);
        self.namesSwitch.enabled = NO;
        self.picturesSwitch.enabled = NO;
    }
}

- (IBAction)namesChanged:(id)sender {
    self.changed = YES;
    self.settings[@"names"] = @(self.namesSwitch.on);
}

- (IBAction)picturesChanged:(id)sender {
    self.changed = YES;
    self.settings[@"pictures"] = @(self.picturesSwitch.on);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Allow"]) {
        [ContactSync requestAddressBookAccessWithCompletionBlock:^(BOOL success) {
            // enable
            if (success) {
                self.changed = YES;
                [self.autoSyncSwitch setOn:YES animated:YES];
                self.settings[@"enabled"] = @(YES);
                self.namesSwitch.enabled = YES;
                self.picturesSwitch.enabled = YES;
            }
        }];
    }
}

@end
