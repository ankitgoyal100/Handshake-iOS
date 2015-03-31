//
//  SignUpViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignUpView.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "MainViewController.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "SocialSetupViewController.h"
#import "TermsViewController.h"
#import "Handshake.h"
#import "BaseNavigationController.h"

@interface SignUpViewController() <UIAlertViewDelegate>

@property (nonatomic) SignUpView *signUpView;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signUpView = [[SignUpView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.signUpView];
    
    self.signUpView.emailField.delegate = self;
    self.signUpView.passwordField.delegate = self;
    self.signUpView.passwordConfirmField.delegate = self;
    
    self.signUpView.navigationItem.hidesBackButton = YES;
    [self.signUpView.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self.signUpView.termsButton addTarget:self action:@selector(terms) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.signUpView.emailField becomeFirstResponder];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.signUpView.loading) return NO;
    
    if (textField == self.signUpView.emailField) {
        [self.signUpView.passwordField becomeFirstResponder];
    } else if (textField == self.signUpView.passwordField) {
        [self.signUpView.passwordConfirmField becomeFirstResponder];
    } else {
        [self.signUpView endEditing:YES];
        
        // check password
        if (![self.signUpView.passwordField.text isEqualToString:self.signUpView.passwordConfirmField.text]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords do not match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;
        }
        
        self.signUpView.navigationItem.leftBarButtonItems = @[];
        
        self.signUpView.loading = YES;
        [[HandshakeClient client] POST:@"/account" parameters:@{ @"email":self.signUpView.emailField.text, @"password":self.signUpView.passwordField.text } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [HandshakeSession loginWithEmail:self.signUpView.emailField.text password:self.signUpView.passwordField.text successBlock:^{
                UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[SocialSetupViewController alloc] initWithNibName:nil bundle:nil]];
                controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:controller animated:YES completion:nil];
                
                [[[UIAlertView alloc] initWithTitle:@"Confirmation Required" message:[NSString stringWithFormat:@"An email with a confirmation link was sent to %@.", [HandshakeSession user].email] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } failedBlock:^(HandshakeSessionError error) {
                [self.signUpView.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
                self.signUpView.loading = NO;
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not sign up at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.signUpView.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
            
            self.signUpView.loading = NO;
            if ([[operation response] statusCode] == 422) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil][@"errors"][0] stringByAppendingString:@"."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not sign up at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
    return NO;
}

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets content = self.signUpView.scrollView.contentInset;
    UIEdgeInsets scrollBar = self.signUpView.scrollView.scrollIndicatorInsets;
    content.bottom = scrollBar.bottom = MAX(self.view.frame.size.height - keyboardRect.origin.y, self.tabBarController.tabBar.frame.size.height);
    self.signUpView.scrollView.contentInset = content;
    self.signUpView.scrollView.scrollIndicatorInsets = scrollBar;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.signUpView.emailField becomeFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)terms {
    BaseNavigationController *controller = [[BaseNavigationController alloc] initWithRootViewController:[[TermsViewController alloc] initWithNibName:nil bundle:nil]];
    controller.navigationBar.barTintColor = LOGO_COLOR;
    controller.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor] };
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
