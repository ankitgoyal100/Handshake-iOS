//
//  ForgotPasswordViewController.m
//  Handshake
//
//  Created by Sam Ober on 10/1/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "Handshake.h"
#import "HandshakeClient.h"

@interface ForgotPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Forgot Password?";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.emailField becomeFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.text length] > 0) {
        self.sendButton.enabled = YES;
        self.sendButton.alpha = 1;
    } else {
        self.sendButton.enabled = NO;
        self.sendButton.alpha = 0.5;
    }
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self send:nil];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.sendButton.enabled = NO;
    self.sendButton.alpha = 0.5;
    
    return YES;
}

- (IBAction)send:(id)sender {
    if ([self.emailField.text length] == 0)
        return;
    
    [self.view endEditing:YES];
    self.sendButton.hidden = YES;
    [self.activityView startAnimating];
    
    [[HandshakeClient client] POST:@"/password" parameters:@{ @"user": @{ @"email":self.emailField.text } } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self cancel:nil];
        [[[UIAlertView alloc] initWithTitle:@"Reset Instructions Sent" message:[@"Instruction to reset your password were sent to " stringByAppendingString:self.emailField.text] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.sendButton.hidden = NO;
        [self.activityView stopAnimating];
        
        if ([[operation response] statusCode] == 422)
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[@"Could not find an account with email " stringByAppendingString:self.emailField.text] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        else
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not send password reset instructions. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
