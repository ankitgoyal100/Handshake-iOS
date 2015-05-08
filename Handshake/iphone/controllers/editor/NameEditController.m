//
//  NameEditController.m
//  Handshake
//
//  Created by Sam Ober on 4/24/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "NameEditController.h"

@interface NameEditController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation NameEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.user) {
        self.firstNameField.text = self.user.firstName;
        self.lastNameField.text = self.user.lastName;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.firstNameField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([self.firstNameField.text length] > 0)
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameField)
        [self.lastNameField becomeFirstResponder];
    
    if (textField == self.lastNameField && self.saveButton.enabled)
        [self save:nil];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.firstNameField)
        self.saveButton.enabled = NO;
    
    return YES;
}

- (void)setUser:(User *)user {
    _user = user;
    
    self.firstNameField.text = user.firstName;
    self.lastNameField.text = user.lastName;
}

- (IBAction)cancel:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nameEdited:last:)] && self.user)
        [self.delegate nameEdited:self.user.firstName last:self.user.lastName];
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    if (self.user) {
        self.user.firstName = self.firstNameField.text;
        self.user.lastName = self.lastNameField.text;
    }
    
    [self cancel:nil];
}

@end
