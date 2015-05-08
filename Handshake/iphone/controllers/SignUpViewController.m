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
#import <QuartzCore/QuartzCore.h>

@interface SignUpViewController() <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set content inset
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.top = 64;
    self.scrollView.contentInset = insets;
    
    // add back button
    [self.navItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.firstNameField becomeFirstResponder];
    
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
    if ([self.activityIndicator isAnimating])
        return NO;
    
    if (textField == self.firstNameField) {
        [self.emailField becomeFirstResponder];
    } else if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self signUp:nil];
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([self.firstNameField.text length] > 0 && [self.emailField.text length] > 0 && [self.passwordField.text length] >= 8) {
        self.signUpButton.enabled = YES;
        self.signUpButton.alpha = 1;
    } else {
        self.signUpButton.enabled = NO;
        self.signUpButton.alpha = 0.5;
    }
    
    return NO;
}

- (IBAction)signUp:(id)sender {
    if ([self.firstNameField.text length] == 0 || [self.emailField.text length] == 0 || [self.passwordField.text length] < 8)
        return;
    
    self.signUpButton.hidden = YES;
    self.navItem.leftBarButtonItems = @[];
    [self.activityIndicator startAnimating];
    [self.view endEditing:YES];
    
    [[HandshakeClient client] POST:@"/account" parameters:@{ @"first_name":self.firstNameField.text, @"email":self.emailField.text, @"password":self.passwordField.text } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [HandshakeSession loginWithEmail:self.emailField.text password:self.passwordField.text successBlock:^(HandshakeSession *session) {
                [self.view.window setRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"]];
        } failedBlock:^(HandshakeSessionError error) {
            [self.navItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
            self.signUpButton.hidden = NO;
            [self.activityIndicator stopAnimating];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not sign up at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.navItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
        self.signUpButton.hidden = NO;
        [self.activityIndicator stopAnimating];

        if ([[operation response] statusCode] == 422) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil][@"errors"][0] stringByAppendingString:@"."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not sign up at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}


//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (self.signUpView.loading) return NO;
//    
//    if (textField == self.signUpView.emailField) {
//        [self.signUpView.passwordField becomeFirstResponder];
//    } else if (textField == self.signUpView.passwordField) {
//        [self.signUpView.passwordConfirmField becomeFirstResponder];
//    } else {
//        [self.signUpView endEditing:YES];
//        
//        // check password
//        if (![self.signUpView.passwordField.text isEqualToString:self.signUpView.passwordConfirmField.text]) {
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords do not match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            return NO;
//        }
//        
//        self.signUpView.navigationItem.leftBarButtonItems = @[];
//        
//        self.signUpView.loading = YES;
//        [[HandshakeClient client] POST:@"/account" parameters:@{ @"email":self.signUpView.emailField.text, @"password":self.signUpView.passwordField.text } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            [HandshakeSession loginWithEmail:self.signUpView.emailField.text password:self.signUpView.passwordField.text successBlock:^(HandshakeSession *session) {
//                UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[SocialSetupViewController alloc] initWithNibName:nil bundle:nil]];
//                controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//                [self presentViewController:controller animated:YES completion:nil];
//            } failedBlock:^(HandshakeSessionError error) {
//                [self.signUpView.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
//                self.signUpView.loading = NO;
//                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not sign up at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            }];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [self.signUpView.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
//            
//            self.signUpView.loading = NO;
//            if ([[operation response] statusCode] == 422) {
//                [[[UIAlertView alloc] initWithTitle:@"Error" message:[[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil][@"errors"][0] stringByAppendingString:@"."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            } else
//                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not sign up at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        }];
//    }
//    return NO;
//}

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets content = self.scrollView.contentInset;
    content.bottom = self.view.frame.size.height - keyboardRect.origin.y;
    self.scrollView.contentInset = content;
    
}

//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
//    [self.signUpView.emailField becomeFirstResponder];
//}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)terms:(id)sender {
    
}

- (void)terms {
    BaseNavigationController *controller = [[BaseNavigationController alloc] initWithRootViewController:[[TermsViewController alloc] initWithNibName:nil bundle:nil]];
    controller.navigationBar.barTintColor = LOGO_COLOR;
    controller.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor] };
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
