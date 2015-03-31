//
//  SettingsViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SettingsViewController.h"
#import "EmailSettingsSection.h"
#import "ResetPasswordSection.h"
#import "LogoutSection.h"
#import "HandshakeCoreDataStore.h"
#import <CoreData/CoreData.h>
#import "SocialAccountsSection.h"

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    
    [self.sections addObject:[[EmailSettingsSection alloc] initWithViewController:self]];
    [self.sections addObject:[[ResetPasswordSection alloc] initWithViewController:self]];
    [self.sections addObject:[[SocialAccountsSection alloc] initWithViewController:self]];
    [self.sections addObject:[[LogoutSection alloc] initWithViewController:self]];
    [self.sections addObject:[[Section alloc] init]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

@end
