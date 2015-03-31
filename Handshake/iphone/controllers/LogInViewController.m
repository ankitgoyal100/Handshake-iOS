//
//  LogInViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LogInViewController.h"
#import "LogInView.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "MainViewController.h"
#import "HandshakeSession.h"
#import "ForgotPasswordViewController.h"
#import "HandshakeClient.h"
#import "BaseNavigationController.h"

@interface LogInViewController() <UIAlertViewDelegate>

@property (nonatomic) LogInView *logInView;

@property (nonatomic) BOOL cancelled;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cancelled = NO;
    
    self.logInView = [[LogInView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.logInView];
    
    self.logInView.emailField.delegate = self;
    self.logInView.passwordField.delegate = self;
    
    [self.logInView.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self.logInView.forgotButton addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.logInView.emailField becomeFirstResponder];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)back {
    self.cancelled = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.logInView.loading) return NO;
    
    if (textField == self.logInView.emailField) {
        [self.logInView.passwordField becomeFirstResponder];
    } else {
        self.logInView.loading = YES;
        [self.logInView endEditing:YES];
        [HandshakeSession loginWithEmail:self.logInView.emailField.text password:self.logInView.passwordField.text successBlock:^{
            if (self.cancelled) return;
            
            MainViewController *controller = [[MainViewController alloc] initWithNibName:nil bundle:nil];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:controller animated:YES completion:nil];
        } failedBlock:^(HandshakeSessionError error) {
            if (self.cancelled) return;
            
            self.logInView.loading = NO;
            if (error == AUTHENTICATION_ERROR)
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email or password was incorrect." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            else
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not log you on at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
    return NO;
}

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets content = self.logInView.scrollView.contentInset;
    UIEdgeInsets scrollBar = self.logInView.scrollView.scrollIndicatorInsets;
    content.bottom = scrollBar.bottom = MAX(self.view.frame.size.height - keyboardRect.origin.y, self.tabBarController.tabBar.frame.size.height);
    self.logInView.scrollView.contentInset = content;
    self.logInView.scrollView.scrollIndicatorInsets = scrollBar;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.logInView.emailField becomeFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)forgotPassword {
    BaseNavigationController *controller = [[BaseNavigationController alloc] initWithRootViewController:[[ForgotPasswordViewController alloc] initWithNibName:nil bundle:nil]];
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
