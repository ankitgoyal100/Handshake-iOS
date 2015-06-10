//
//  EmailEditViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/10/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "ChangeEmailViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"

@interface ChangeEmailViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation ChangeEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    self.emailField.text = [[HandshakeSession currentSession] account].email;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.emailField becomeFirstResponder];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([text length] != 0 && ![text isEqualToString:[[HandshakeSession currentSession] account].email])
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.saveButton.enabled = NO;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.saveButton.enabled)
        [self save:nil];
    
    return NO;
}

- (IBAction)save:(id)sender {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
    [self.emailField resignFirstResponder];
    self.emailField.userInteractionEnabled = NO;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"email"] = self.emailField.text;
    [[HandshakeClient client] PUT:@"/account" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[HandshakeSession currentSession] account].email = responseObject[@"user"][@"email"];
        [self back];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.saveButton.enabled = NO;
        self.navigationItem.rightBarButtonItem = self.saveButton;
        self.emailField.userInteractionEnabled = YES;
        
        if ([[operation response] statusCode] == 422) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil][@"errors"][0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not update email. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.emailField becomeFirstResponder];
}

@end
