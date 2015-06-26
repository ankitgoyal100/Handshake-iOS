//
//  LogInViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LogInViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "MainViewController.h"
#import "HandshakeSession.h"
#import "ForgotPasswordViewController.h"
#import "HandshakeClient.h"
#import "BaseNavigationController.h"
#import "CardServerSync.h"

@interface LogInViewController()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UIButton *logInButton;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Log In";
    
    [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self.emailField becomeFirstResponder];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([self.emailField.text length] > 0 && [self.passwordField.text length] > 0) {
        self.logInButton.enabled = YES;
        self.logInButton.alpha = 1;
    } else {
        self.logInButton.enabled = NO;
        self.logInButton.alpha = 0.5;
    }
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.logInButton.enabled = NO;
    self.logInButton.alpha = 0.5;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self logIn:nil];
    }
    
    return NO;
}

- (IBAction)logIn:(id)sender {
    if ([self.emailField.text length] == 0 || [self.passwordField.text length] == 0)
        return;
    
    self.logInButton.hidden = YES;
    self.navItem.leftBarButtonItems = @[];
    [self.activityView startAnimating];
    [self.view endEditing:YES];
    
    [HandshakeSession loginWithEmail:self.emailField.text password:self.passwordField.text successBlock:^(HandshakeSession *session) {
        [HandshakeSession sync];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [self.view.window setRootViewController:[storyboard instantiateInitialViewController]];
    } failedBlock:^(HandshakeSessionError error) {
        self.logInButton.hidden = NO;
        [self.navItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
        [self.activityView stopAnimating];
        
        if (error == AUTHENTICATION_ERROR)
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email or password was incorrect." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        else
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not log you on at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets content = self.scrollView.contentInset;
    content.bottom = self.view.frame.size.height - keyboardRect.origin.y;
    self.scrollView.contentInset = content;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)forgotPassword:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
