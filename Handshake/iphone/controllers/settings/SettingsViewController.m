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

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    
    [self.sections addObject:[[EmailSettingsSection alloc] initWithViewController:self]];
    [self.sections addObject:[[ResetPasswordSection alloc] initWithViewController:self]];
    [self.sections addObject:[[LogoutSection alloc] initWithViewController:self]];
    [self.sections addObject:[[Section alloc] init]];
}

@end
