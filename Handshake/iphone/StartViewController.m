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

@property (nonatomic, strong) StartView *startView;

@end

@implementation StartViewController

- (StartView *)startView {
    if (!_startView) {
        _startView = [[StartView alloc] initWithFrame:self.view.bounds];
    }
    return _startView;
}

- (id)initWithLoading:(BOOL)loading {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _loading = loading;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.startView];
    
    self.loading = self.loading;
    
    [self.startView.signUpButton addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];
    [self.startView.logInButton addTarget:self action:@selector(logIn) forControlEvents:UIControlEventTouchUpInside];
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if (loading) {
        self.startView.signUpButton.hidden = YES;
        self.startView.logInButton.hidden = YES;
    } else {
        self.startView.signUpButton.hidden = NO;
        self.startView.logInButton.hidden = NO;
    }
}

@end
