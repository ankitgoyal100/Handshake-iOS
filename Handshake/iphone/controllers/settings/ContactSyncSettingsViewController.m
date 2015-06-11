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

@interface ContactSyncSettingsViewController ()

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
    if (![self.settings[@"enabled"] boolValue]) {
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

@end
