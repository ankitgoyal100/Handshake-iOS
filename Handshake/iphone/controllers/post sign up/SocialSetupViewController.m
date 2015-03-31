//
//  SocialSetupViewController.m
//  Handshake
//
//  Created by Sam Ober on 10/6/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SocialSetupViewController.h"
#import "SocialAccountsSection.h"
#import "SocialSetupMessageSection.h"
#import "CardSetupViewController.h"
#import "MainViewController.h"

@interface SocialSetupViewController ()

@end

@implementation SocialSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    nextButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    [self.sections addObject:[[SocialSetupMessageSection alloc] initWithViewController:self]];
    [self.sections addObject:[[SocialAccountsSection alloc] initWithViewController:self]];
}

- (void)next {
    CardSetupViewController *controller = [[CardSetupViewController alloc] initWithDismissBlock:^{
        MainViewController *controller = [[MainViewController alloc] initWithNibName:nil bundle:nil];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:controller animated:YES completion:nil];
    }];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
