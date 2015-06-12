//
//  StartViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "StartViewController.h"
#import "SignUpViewController.h"
#import "LogInViewController.h"
#import "HandshakeSession.h"
#import "MainViewController.h"
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>

@interface StartViewController ()

@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (nonatomic, strong) UIViewController *signUpController;
@property (weak, nonatomic) IBOutlet UIImageView *background10View;
@property (weak, nonatomic) IBOutlet UIImageView *background20View;


@end

@implementation StartViewController

- (id)initWithLoading:(BOOL)loading {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _loading = loading;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loading = self.loading;
    
    self.signUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.navigationController.navigationBarHidden = YES;
    
    [super viewWillAppear:animated];
}

- (IBAction)signUp:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)logIn:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)signUp {
    
}

- (void)logIn {
    LogInViewController *controller = [[LogInViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
