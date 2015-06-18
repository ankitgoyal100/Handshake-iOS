//
//  NotificationSettingsViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/17/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "NotificationsHelper.h"

@interface NotificationSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *enabledSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *requestsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *contactsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *updatedInfoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *groupMembersSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *contactJoinedSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *suggestionsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *featuresSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *offersSwitch;

@property (nonatomic, strong) NSMutableDictionary *settings;

@end

@implementation NotificationSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Notifications";
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.settings = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"notifications_settings"]];
    
    self.enabledSwitch.on = [self.settings[@"enabled"] boolValue];
    
    self.requestsSwitch.on = [self.settings[@"requests"] boolValue];
    self.contactsSwitch.on = [self.settings[@"new_contacts"] boolValue];
    self.updatedInfoSwitch.on = [self.settings[@"new_contact_information"] boolValue];
    self.groupMembersSwitch.on = [self.settings[@"new_group_members"] boolValue];
    self.contactJoinedSwitch.on = [self.settings[@"contact_joined"] boolValue];
    self.suggestionsSwitch.on = [self.settings[@"suggestions"] boolValue];
    self.featuresSwitch.on = [self.settings[@"new_features"] boolValue];
    self.offersSwitch.on = [self.settings[@"offers"] boolValue];
    
    [self enabled:nil];
}

- (void)back {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.settings forKey:@"notifications_settings"];
    [defaults synchronize];
    
    [[NotificationsHelper sharedHelper] updateSettings];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)enabled:(id)sender {
    self.settings[@"enabled"] = @(self.enabledSwitch.on);
    
    self.requestsSwitch.enabled = self.enabledSwitch.on;
    self.contactsSwitch.enabled = self.enabledSwitch.on;
    self.updatedInfoSwitch.enabled = self.enabledSwitch.on;
    self.groupMembersSwitch.enabled = self.enabledSwitch.on;
    self.contactJoinedSwitch.enabled = self.enabledSwitch.on;
    self.suggestionsSwitch.enabled = self.enabledSwitch.on;
    self.featuresSwitch.enabled = self.enabledSwitch.on;
    self.offersSwitch.enabled = self.enabledSwitch.on;
}

- (IBAction)requests:(id)sender {
    self.settings[@"requests"] = @(self.requestsSwitch.on);
}

- (IBAction)contacts:(id)sender {
    self.settings[@"new_contacts"] = @(self.contactsSwitch.on);
}

- (IBAction)updatedInfo:(id)sender {
    self.settings[@"new_contact_information"] = @(self.updatedInfoSwitch.on);
}

- (IBAction)groupMembers:(id)sender {
    self.settings[@"new_group_members"] = @(self.groupMembersSwitch.on);
}

- (IBAction)contactJoined:(id)sender {
    self.settings[@"contact_joined"] = @(self.contactJoinedSwitch.on);
}

- (IBAction)suggestions:(id)sender {
    self.settings[@"suggestions"] = @(self.suggestionsSwitch.on);
}

- (IBAction)newFeatures:(id)sender {
    self.settings[@"new_features"] = @(self.featuresSwitch.on);
}

- (IBAction)offers:(id)sender {
    self.settings[@"offers"] = @(self.offersSwitch.on);
}

@end
