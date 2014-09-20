//
//  StartViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "StartViewController.h"
#import "StartView.h"
#import "SignUpViewController.h"
#import "LogInViewController.h"
#import "HandshakeSession.h"
#import "MainViewController.h"

@interface StartViewController ()

@property (nonatomic) StartView *startView;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startView = [[StartView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.startView];
    
    [self.startView.signUpButton addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];
    [self.startView.logInButton addTarget:self action:@selector(logIn) forControlEvents:UIControlEventTouchUpInside];
    
    if ([HandshakeSession restoreSession]) {
        MainViewController *controller = [[MainViewController alloc] initWithNibName:nil bundle:nil];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    [super viewWillAppear:animated];
}

- (void)signUp {
    SignUpViewController *controller = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)logIn {
    LogInViewController *controller = [[LogInViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
