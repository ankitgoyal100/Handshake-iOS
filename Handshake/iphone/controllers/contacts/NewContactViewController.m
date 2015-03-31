//
//  NewContactViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "NewContactViewController.h"

@implementation NewContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"New Contact";
    
    self.navigationItem.hidesBackButton = YES;
    
    //[self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    exitButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItems = @[exitButton];
}

- (void)exit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
