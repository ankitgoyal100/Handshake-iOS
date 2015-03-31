//
//  ForgotPasswordViewController.m
//  Handshake
//
//  Created by Sam Ober on 10/1/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "ForgotPasswordView.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "Handshake.h"
#import "HandshakeClient.h"

@interface ForgotPasswordViewController () <UITextFieldDelegate>

@property (nonatomic) ForgotPasswordView *emailView;

@property (nonatomic, strong) NSString *email;

@end

@implementation ForgotPasswordViewController

- (ForgotPasswordView *)emailView {
    if (!_emailView) {
        _emailView = [[ForgotPasswordView alloc] initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, 50)];
    }
    return _emailView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Enter Your Email";
    self.view.backgroundColor = SUPER_LIGHT_GRAY;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self.view addSubview:self.emailView];
    self.emailView.emailField.text = self.email;
    self.emailView.emailField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barTintColor = LOGO_COLOR;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.emailView.emailField becomeFirstResponder];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length] > 0) {
        [self.view endEditing:YES];
        
        NSString *email = textField.text;
        self.emailView.loading = YES;
        
        [[HandshakeClient client] POST:@"/password" parameters:@{ @"user": @{ @"email":email } } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[[UIAlertView alloc] initWithTitle:@"Reset Instructions Sent" message:[@"Instruction to reset your password were sent to " stringByAppendingString:email] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.emailView.loading = NO;
            if ([[operation response] statusCode] == 422)
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[@"Could not find an account with email " stringByAppendingString:email] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            else
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not send password reset instructions. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
    
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
