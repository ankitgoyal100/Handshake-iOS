//
//  NewContactViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "NewContactViewController.h"
#import "ContactHeaderSection.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "BasicInfoSection.h"
#import "ContactSocialSection.h"

@implementation NewContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Shake";
    
    //[self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    exitButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = exitButton;
    
    [self.sections addObject:[[ContactHeaderSection alloc] initWithViewController:self]];
    [self.sections addObject:[[BasicInfoSection alloc] initWithViewController:self]];
    [self.sections addObject:[[ContactSocialSection alloc] initWithViewController:self]];
}

- (void)exit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
